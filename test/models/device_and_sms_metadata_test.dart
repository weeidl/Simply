import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simply/models/device.dart';
import 'package:simply/models/device_sim_card.dart';
import 'package:simply/models/incoming_sms_payload.dart';
import 'package:simply/security/secure_storage_service.dart';
import 'package:simply/services/device_runtime_service.dart';

class _FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> values = {};

  @override
  Future<void> writeValue(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<String?> readValue(String key) async => values[key];
}

void main() {
  group('Device', () {
    test('restores sim cards and daily activity from map', () {
      final device = Device.fromMap({
        'user_id': 'user-1',
        'device_name': 'Redmi 9 Pro',
        'device_id': 'device-1',
        'platform': 'android',
        'is_main_device': true,
        'battery_level': 91,
        'network_type': 'lte',
        'sim_count': 2,
        'active_sim_slot': 2,
        'sim_cards': [
          {
            'slot': 1,
            'subscription_id': 11,
            'carrier_name': 'Turkcell',
            'display_name': 'Primary',
            'is_active': false,
          },
          {
            'slot': 2,
            'subscription_id': 12,
            'carrier_name': 'MTC',
            'display_name': 'Travel',
            'is_active': true,
          },
        ],
        'today_message_count': 47,
        'today_sparkline': [4, 6, 5, 9, 7, 16],
        'today_sparkline_day': '2026-04-23',
        'last_message_at': Timestamp.fromDate(DateTime.utc(2026, 4, 23, 12)),
      });

      expect(device.simCount, 2);
      expect(device.activeSimSlot, 2);
      expect(device.todayMessageCount, 47);
      expect(device.todaySparkline, [4, 6, 5, 9, 7, 16]);
      expect(device.isReceiverOnly, isFalse);
      expect(
        device.simCards,
        equals([
          const DeviceSimCard(
            slot: 1,
            subscriptionId: 11,
            carrierName: 'Turkcell',
            displayName: 'Primary',
            isActive: false,
          ),
          const DeviceSimCard(
            slot: 2,
            subscriptionId: 12,
            carrierName: 'MTC',
            displayName: 'Travel',
            isActive: true,
          ),
        ]),
      );
    });
  });

  group('Device.isOnlineAt', () {
    Device makeDevice({DateTime? updatedAt}) {
      return Device(
        userId: 'user-1',
        deviceName: 'Redmi 9 Pro',
        deviceId: 'device-1',
        dateUpdateInfo:
            updatedAt == null ? null : Timestamp.fromDate(updatedAt.toUtc()),
      );
    }

    test('reports offline when the device has no heartbeat yet', () {
      final device = makeDevice();
      expect(device.isOnlineAt(DateTime.utc(2026, 4, 23, 12)), isFalse);
    });

    test('reports online within the stale window', () {
      final now = DateTime.utc(2026, 4, 23, 12);
      final device = makeDevice(
        updatedAt: now.subtract(const Duration(minutes: 3)),
      );
      expect(device.isOnlineAt(now), isTrue);
    });

    test('reports offline once the stale window has passed', () {
      final now = DateTime.utc(2026, 4, 23, 12);
      final device = makeDevice(
        updatedAt: now.subtract(Device.onlineStaleWindow * 2),
      );
      expect(device.isOnlineAt(now), isFalse);
    });
  });

  group('IncomingSmsPayload', () {
    test('passes source metadata into conversation and message models', () {
      final payload = IncomingSmsPayload(
        address: 'Bank',
        body: 'Code 1234',
        receivedAt: DateTime.utc(2026, 4, 23, 9, 10),
        sourceDeviceId: 'device-1',
        sourceDeviceName: 'Redmi 9 Pro',
        sourcePlatform: 'android',
        sourceSubscriptionId: 12,
        sourceSimSlot: 2,
        sourceCarrier: 'MTC',
      );

      final conversation = payload.toConversation();
      final message = payload.toMessage();

      expect(conversation.sourceDeviceId, 'device-1');
      expect(conversation.sourceDeviceName, 'Redmi 9 Pro');
      expect(conversation.sourcePlatform, 'android');
      expect(conversation.sourceSimSlot, 2);
      expect(conversation.sourceCarrier, 'MTC');
      expect(message.sourceDeviceId, 'device-1');
      expect(message.sourceDeviceName, 'Redmi 9 Pro');
      expect(message.sourceSimSlot, 2);
      expect(message.sourceCarrier, 'MTC');
    });
  });

  group('DeviceRuntimeService.enrichIncomingPayload', () {
    test('does not guess the active SIM when SMS subscription is unknown',
        () async {
      final storage = _FakeSecureStorageService();
      final service = DeviceRuntimeService(secureStorageService: storage);
      await service.writeCurrentContext(
        const CurrentDeviceContext(
          deviceId: 'device-1',
          deviceName: 'Redmi 9',
          platform: 'android',
          activeSimSlot: 2,
          simCards: [
            DeviceSimCard(
              slot: 1,
              subscriptionId: 11,
              carrierName: 'A1',
              isActive: false,
            ),
            DeviceSimCard(
              slot: 2,
              subscriptionId: 12,
              carrierName: 'Yettel',
              isActive: true,
            ),
          ],
        ),
      );

      final enriched = await service.enrichIncomingPayload(
        IncomingSmsPayload(
          address: 'Bank',
          body: 'Code 1234',
          receivedAt: DateTime.utc(2026, 4, 24, 10),
        ),
      );

      expect(enriched.sourceDeviceName, 'Redmi 9');
      expect(enriched.sourceSimSlot, isNull);
      expect(enriched.sourceCarrier, isNull);
    });

    test('uses the exact SMS subscription when it is available', () async {
      final storage = _FakeSecureStorageService();
      final service = DeviceRuntimeService(secureStorageService: storage);
      await service.writeCurrentContext(
        const CurrentDeviceContext(
          deviceId: 'device-1',
          deviceName: 'Redmi 9',
          platform: 'android',
          activeSimSlot: 2,
          simCards: [
            DeviceSimCard(
              slot: 1,
              subscriptionId: 11,
              carrierName: 'A1',
              isActive: false,
            ),
            DeviceSimCard(
              slot: 2,
              subscriptionId: 12,
              carrierName: 'Yettel',
              isActive: true,
            ),
          ],
        ),
      );

      final enriched = await service.enrichIncomingPayload(
        IncomingSmsPayload(
          address: 'Bank',
          body: 'Code 1234',
          receivedAt: DateTime.utc(2026, 4, 24, 10),
          sourceSubscriptionId: 11,
        ),
      );

      expect(enriched.sourceSimSlot, 1);
      expect(enriched.sourceCarrier, 'A1');
    });
  });
}
