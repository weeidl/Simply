import 'dart:convert';
import 'dart:io';

import 'package:another_telephony/telephony.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:simply/models/device_sim_card.dart';
import 'package:simply/models/incoming_sms_payload.dart';
import 'package:simply/security/secure_storage_service.dart';

class DeviceIdentity {
  final String name;
  final String platform;

  const DeviceIdentity({
    required this.name,
    required this.platform,
  });
}

class DeviceRuntimeSnapshot {
  final int? batteryLevel;
  final String? networkType;
  final int? simCount;
  final int? activeSimSlot;
  final List<DeviceSimCard> simCards;

  const DeviceRuntimeSnapshot({
    this.batteryLevel,
    this.networkType,
    this.simCount,
    this.activeSimSlot,
    this.simCards = const [],
  });
}

class CurrentDeviceContext {
  final String deviceId;
  final String deviceName;
  final String platform;
  final int? activeSimSlot;
  final List<DeviceSimCard> simCards;

  const CurrentDeviceContext({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    this.activeSimSlot,
    this.simCards = const [],
  });

  factory CurrentDeviceContext.fromJson(Map<String, dynamic> json) {
    final rawCards = json['sim_cards'];
    final simCards = rawCards is Iterable
        ? rawCards
            .whereType<Map>()
            .map((item) =>
                DeviceSimCard.fromMap(Map<String, dynamic>.from(item)))
            .toList()
        : const <DeviceSimCard>[];

    return CurrentDeviceContext(
      deviceId: json['device_id']?.toString() ?? '',
      deviceName: json['device_name']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      activeSimSlot: (json['active_sim_slot'] as num?)?.toInt(),
      simCards: simCards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'platform': platform,
      'active_sim_slot': activeSimSlot,
      'sim_cards': simCards.map((item) => item.toMap()).toList(),
    };
  }
}

class DeviceRuntimeService {
  static const _runtimeStorageKey = 'device.runtime_context';
  static const _channel = MethodChannel('simply/device_runtime');

  final DeviceInfoPlugin _deviceInfo;
  final Battery _battery;
  final Telephony? _telephonyOverride;
  final SecureStorageService _secureStorageService;

  DeviceRuntimeService({
    DeviceInfoPlugin? deviceInfo,
    Battery? battery,
    Telephony? telephony,
    SecureStorageService? secureStorageService,
  })  : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _battery = battery ?? Battery(),
        _telephonyOverride = telephony,
        _secureStorageService = secureStorageService ?? SecureStorageService();

  Future<DeviceIdentity> readDeviceIdentity() async {
    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return DeviceIdentity(name: iosInfo.name, platform: 'ios');
    }

    final androidInfo = await _deviceInfo.androidInfo;
    return DeviceIdentity(name: androidInfo.model, platform: 'android');
  }

  Future<DeviceRuntimeSnapshot> readRuntimeSnapshot({
    required bool includeBattery,
    required bool includeNetwork,
  }) async {
    int? batteryLevel;
    String? networkType;

    if (includeBattery) {
      try {
        batteryLevel = await _battery.batteryLevel;
      } catch (_) {}
    }

    if (Platform.isAndroid && includeNetwork) {
      try {
        networkType = (await _telephony.dataNetworkType).name;
      } catch (_) {}
    }

    if (!Platform.isAndroid) {
      return DeviceRuntimeSnapshot(
        batteryLevel: batteryLevel,
        networkType: networkType,
      );
    }

    try {
      final runtimeInfo =
          await _channel.invokeMethod<dynamic>('getRuntimeInfo');
      final map = runtimeInfo is Map
          ? Map<String, dynamic>.from(runtimeInfo)
          : const <String, dynamic>{};
      final rawCards = map['sim_cards'];
      final simCards = rawCards is Iterable
          ? rawCards
              .whereType<Map>()
              .map((item) =>
                  DeviceSimCard.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : const <DeviceSimCard>[];

      return DeviceRuntimeSnapshot(
        batteryLevel: batteryLevel,
        networkType: networkType,
        simCount: (map['sim_count'] as num?)?.toInt(),
        activeSimSlot: (map['active_sim_slot'] as num?)?.toInt(),
        simCards: simCards,
      );
    } on PlatformException {
      return DeviceRuntimeSnapshot(
        batteryLevel: batteryLevel,
        networkType: networkType,
      );
    }
  }

  Future<void> writeCurrentContext(CurrentDeviceContext context) {
    return _secureStorageService.writeValue(
      _runtimeStorageKey,
      jsonEncode(context.toJson()),
    );
  }

  Future<CurrentDeviceContext?> readCurrentContext() async {
    try {
      final raw = await _secureStorageService.readValue(_runtimeStorageKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return CurrentDeviceContext.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<IncomingSmsPayload> enrichIncomingPayload(
    IncomingSmsPayload payload,
  ) async {
    final context = await readCurrentContext();
    if (context == null) return payload;

    final matchedSim = _resolveSim(
      simCards: context.simCards,
      subscriptionId: payload.sourceSubscriptionId,
      fallbackActiveSlot: context.activeSimSlot,
    );

    return payload.copyWith(
      sourceDeviceId: payload.sourceDeviceId ?? context.deviceId,
      sourceDeviceName: payload.sourceDeviceName ?? context.deviceName,
      sourcePlatform: payload.sourcePlatform ?? context.platform,
      sourceSimSlot: payload.sourceSimSlot ?? matchedSim?.slot,
      sourceCarrier: payload.sourceCarrier ??
          matchedSim?.carrierName ??
          matchedSim?.displayName,
    );
  }

  DeviceSimCard? _resolveSim({
    required List<DeviceSimCard> simCards,
    required int? subscriptionId,
    required int? fallbackActiveSlot,
  }) {
    if (simCards.isEmpty) return null;

    if (subscriptionId != null) {
      final exact =
          simCards.where((card) => card.subscriptionId == subscriptionId);
      if (exact.isNotEmpty) return exact.first;
    }

    final active = simCards.where((card) => card.isActive);
    if (active.isNotEmpty) return active.first;

    if (fallbackActiveSlot != null) {
      final slotMatch =
          simCards.where((card) => card.slot == fallbackActiveSlot);
      if (slotMatch.isNotEmpty) return slotMatch.first;
    }

    return simCards.length == 1 ? simCards.first : null;
  }

  Telephony get _telephony => _telephonyOverride ?? Telephony.instance;
}
