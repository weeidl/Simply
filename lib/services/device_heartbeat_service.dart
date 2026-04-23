import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:simply/repositories/device_repository.dart';
import 'package:simply/security/secure_storage_service.dart';
import 'package:simply/services/device_runtime_service.dart';

/// Writes a lightweight liveness record for the current device while the app
/// is foregrounded so other devices can tell when it was last seen.
///
/// Intentionally independent of SMS arrival: an empty-inbox Android still needs
/// to look "online". SMS writes their own `date_update_info` when they land, so
/// the two paths complement each other.
class DeviceHeartbeatService {
  final DeviceRepository _deviceRepository;
  final DeviceRuntimeService _deviceRuntimeService;
  final SecureStorageService _secureStorageService;
  final Duration _interval;

  Timer? _timer;
  bool _inFlight = false;

  DeviceHeartbeatService({
    DeviceRepository? deviceRepository,
    DeviceRuntimeService? deviceRuntimeService,
    SecureStorageService? secureStorageService,
    Duration interval = const Duration(minutes: 2),
  })  : _deviceRepository = deviceRepository ?? DeviceRepository(),
        _deviceRuntimeService = deviceRuntimeService ?? DeviceRuntimeService(),
        _secureStorageService = secureStorageService ?? SecureStorageService(),
        _interval = interval;

  /// Starts the periodic heartbeat. Calling [start] again is idempotent — the
  /// existing timer is left in place and a single immediate beat is issued.
  void start() {
    _timer ??= Timer.periodic(_interval, (_) => _beat());
    unawaited(_beat());
  }

  /// Fires a single beat — useful on resume / after sync flushes.
  Future<void> beatNow() => _beat();

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _beat() async {
    if (!Platform.isAndroid) return;
    if (_inFlight) return;
    _inFlight = true;
    try {
      final deviceId = await _secureStorageService.readDeviceId();
      if (deviceId == null || deviceId.isEmpty) return;

      final snapshot = await _deviceRuntimeService.readRuntimeSnapshot(
        includeBattery: true,
        includeNetwork: true,
      );

      await _deviceRepository.heartbeat(
        deviceId: deviceId,
        batteryLevel: snapshot.batteryLevel,
        networkType: snapshot.networkType,
        simCount: snapshot.simCount,
        activeSimSlot: snapshot.activeSimSlot,
        simCards: snapshot.simCards,
      );
    } catch (error, stack) {
      debugPrint('[DeviceHeartbeatService] beat failed: $error\n$stack');
    } finally {
      _inFlight = false;
    }
  }
}
