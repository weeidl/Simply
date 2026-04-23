import 'package:flutter_test/flutter_test.dart';
import 'package:simply/models/incoming_sms_payload.dart';
import 'package:simply/repositories/pending_incoming_sms_repository.dart';
import 'package:simply/security/secure_storage_service.dart';

class _FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> writeValue(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<String?> readValue(String key) async {
    return _values[key];
  }

  @override
  Future<void> deleteValue(String key) async {
    _values.remove(key);
  }
}

void main() {
  group('PendingIncomingSmsRepository', () {
    late _FakeSecureStorageService storage;
    late PendingIncomingSmsRepository repository;

    setUp(() {
      storage = _FakeSecureStorageService();
      repository = PendingIncomingSmsRepository(
        secureStorageService: storage,
      );
    });

    test('persists queued SMS payloads', () async {
      final payload = IncomingSmsPayload(
        address: '+381601234567',
        body: 'Your OTP is 1234',
        receivedAt: DateTime.utc(2026, 4, 23, 10, 30),
      );

      await repository.enqueue(payload);

      final items = await repository.readAll();
      expect(items, hasLength(1));
      expect(items.single.address, payload.address);
      expect(items.single.body, payload.body);
      expect(items.single.dedupeKey, payload.dedupeKey);
    });

    test('deduplicates the same SMS payload', () async {
      final payload = IncomingSmsPayload(
        address: '+381601234567',
        body: 'Your OTP is 1234',
        receivedAt: DateTime.utc(2026, 4, 23, 10, 30),
      );

      await repository.enqueue(payload);
      await repository.enqueue(payload);

      final items = await repository.readAll();
      expect(items, hasLength(1));
    });

    test('removes only processed payloads', () async {
      final first = IncomingSmsPayload(
        address: '+381601234567',
        body: 'First',
        receivedAt: DateTime.utc(2026, 4, 23, 10, 30),
      );
      final second = IncomingSmsPayload(
        address: '+381601111111',
        body: 'Second',
        receivedAt: DateTime.utc(2026, 4, 23, 10, 31),
      );

      await repository.enqueue(first);
      await repository.enqueue(second);
      await repository.removeMany([first.dedupeKey]);

      final items = await repository.readAll();
      expect(items, hasLength(1));
      expect(items.single.dedupeKey, second.dedupeKey);
    });
  });
}
