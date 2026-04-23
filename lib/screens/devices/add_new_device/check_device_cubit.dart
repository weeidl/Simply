import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/device.dart';
import 'package:simply/repositories/device_repository.dart';
import 'package:simply/services/device_runtime_service.dart';
import 'package:simply/security/secure_storage_service.dart';
import 'package:uuid/uuid.dart';

part 'check_device_state.dart';

class CheckDeviceCubit extends Cubit<CheckDeviceState> {
  final DeviceRepository _deviceRepository;
  final SecureStorageService _secureStorageService;
  final DeviceRuntimeService _deviceRuntimeService;
  final DeviceInfoPlugin _deviceInfo;
  final Uuid _uuid;

  CheckDeviceCubit({
    DeviceRepository? deviceRepository,
    SecureStorageService? secureStorageService,
    DeviceRuntimeService? deviceRuntimeService,
    DeviceInfoPlugin? deviceInfo,
    Uuid? uuid,
  })  : _deviceRepository = deviceRepository ?? DeviceRepository(),
        _secureStorageService = secureStorageService ?? SecureStorageService(),
        _deviceRuntimeService = deviceRuntimeService ?? DeviceRuntimeService(),
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _uuid = uuid ?? const Uuid(),
        super(CheckDeviceState());

  Future<void> checkDevice() async {
    final stableDeviceId = await _stableDeviceId();
    final existingDevices = await _deviceRepository.fetch();
    final hasCurrentDevice = existingDevices.any(
      (device) => device.deviceId == stableDeviceId,
    );

    await setBaseInfoForDevice(deviceId: stableDeviceId);

    if (!hasCurrentDevice && Platform.isAndroid) {
      emit(state.copyWith(status: DeviceSettingStatus.showModal));
    }
  }

  Future<void> saveSettingDevice({
    required bool isSMSEnabled,
    required bool isNetworkEnabled,
    required bool isChargingEnabled,
    String? deviceId,
  }) async {
    final resolvedDeviceId = deviceId ?? await _stableDeviceId();
    final identity = await _deviceRuntimeService.readDeviceIdentity();
    final runtime = await _deviceRuntimeService.readRuntimeSnapshot(
      includeBattery: isChargingEnabled,
      includeNetwork: isNetworkEnabled,
    );

    await _deviceRepository.addBatteryAndNetworkStatus(
      isMainDevice: isSMSEnabled,
      batteryStatus: runtime.batteryLevel,
      networkTypeStatus: runtime.networkType,
      simCount: runtime.simCount,
      activeSimSlot: runtime.activeSimSlot,
      simCards: runtime.simCards,
      deviceId: resolvedDeviceId,
    );

    await _deviceRuntimeService.writeCurrentContext(
      CurrentDeviceContext(
        deviceId: resolvedDeviceId,
        deviceName: identity.name,
        platform: identity.platform,
        activeSimSlot: runtime.activeSimSlot,
        simCards: runtime.simCards,
      ),
    );
  }

  Future<void> setBaseInfoForDevice({String? deviceId}) async {
    final resolvedDeviceId = deviceId ?? await _stableDeviceId();
    final identity = await _deviceRuntimeService.readDeviceIdentity();
    final runtime = await _deviceRuntimeService.readRuntimeSnapshot(
      includeBattery: false,
      includeNetwork: false,
    );

    await _deviceRepository.update(
      device: Device(
        userId: _deviceRepository.id,
        deviceId: resolvedDeviceId,
        deviceName: identity.name,
        platform: identity.platform,
        simCount: runtime.simCount,
        activeSimSlot: runtime.activeSimSlot,
        simCards: runtime.simCards,
      ),
    );

    await _deviceRuntimeService.writeCurrentContext(
      CurrentDeviceContext(
        deviceId: resolvedDeviceId,
        deviceName: identity.name,
        platform: identity.platform,
        activeSimSlot: runtime.activeSimSlot,
        simCards: runtime.simCards,
      ),
    );
  }

  Future<String> _stableDeviceId() async {
    final storedDeviceId = await _secureStorageService.readDeviceId();
    if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
      return storedDeviceId;
    }

    final generatedDeviceId = await _generateStableDeviceId();
    await _secureStorageService.writeDeviceId(generatedDeviceId);
    return generatedDeviceId;
  }

  Future<String> _generateStableDeviceId() async {
    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      final vendorId = iosInfo.identifierForVendor?.trim();
      if (vendorId != null && vendorId.isNotEmpty) {
        return vendorId;
      }

      return _uuid.v5(
        Namespace.url.value,
        'ios:${iosInfo.model}:${iosInfo.name}:${iosInfo.systemVersion}:${iosInfo.utsname.machine}',
      );
    }

    final androidInfo = await _deviceInfo.androidInfo;
    final fingerprintSeed = [
      androidInfo.manufacturer,
      androidInfo.model,
      androidInfo.device,
      androidInfo.fingerprint,
      androidInfo.hardware,
      androidInfo.host,
      androidInfo.serialNumber,
    ].where((value) => value.trim().isNotEmpty).join('|');

    if (fingerprintSeed.isNotEmpty) {
      return _uuid.v5(Namespace.url.value, 'android:$fingerprintSeed');
    }

    return _uuid.v4();
  }
}
