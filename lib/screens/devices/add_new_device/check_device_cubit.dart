import 'dart:async';
import 'dart:io';

import 'package:another_telephony/telephony.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/device.dart';
import 'package:simply/repositories/device_repository.dart';
import 'package:simply/security/secure_storage_service.dart';
import 'package:uuid/uuid.dart';

part 'check_device_state.dart';

class CheckDeviceCubit extends Cubit<CheckDeviceState> {
  final DeviceRepository _deviceRepository;
  final SecureStorageService _secureStorageService;
  final DeviceInfoPlugin deviceInfo;
  final Uuid _uuid;

  CheckDeviceCubit({
    DeviceRepository? deviceRepository,
    SecureStorageService? secureStorageService,
    DeviceInfoPlugin? deviceInfo,
    Uuid? uuid,
  })  : _deviceRepository = deviceRepository ?? DeviceRepository(),
        _secureStorageService = secureStorageService ?? SecureStorageService(),
        deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
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

    int? batteryLevel;
    String? network;

    if (isChargingEnabled) {
      batteryLevel = await Battery().batteryLevel;
    }

    if (Platform.isAndroid && isNetworkEnabled) {
      final networkType = await Telephony.instance.dataNetworkType;
      network = networkType.name;
    }

    await _deviceRepository.addBatteryAndNetworkStatus(
      isMainDevice: isSMSEnabled,
      batteryStatus: batteryLevel,
      networkTypeStatus: network,
      deviceId: resolvedDeviceId,
    );
  }

  Future<void> setBaseInfoForDevice({String? deviceId}) async {
    final resolvedDeviceId = deviceId ?? await _stableDeviceId();
    final info = await _readDeviceInfo();

    await _deviceRepository.update(
      device: Device(
        userId: _deviceRepository.id,
        deviceId: resolvedDeviceId,
        deviceName: info.name,
        platform: Platform.operatingSystem,
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
      final iosInfo = await deviceInfo.iosInfo;
      final vendorId = iosInfo.identifierForVendor?.trim();
      if (vendorId != null && vendorId.isNotEmpty) {
        return vendorId;
      }

      return _uuid.v5(
        Namespace.url.value,
        'ios:${iosInfo.model}:${iosInfo.name}:${iosInfo.systemVersion}:${iosInfo.utsname.machine}',
      );
    }

    final androidInfo = await deviceInfo.androidInfo;
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

  Future<_ResolvedDeviceInfo> _readDeviceInfo() async {
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return _ResolvedDeviceInfo(name: iosInfo.name);
    }

    final androidInfo = await deviceInfo.androidInfo;
    return _ResolvedDeviceInfo(name: androidInfo.model);
  }
}

class _ResolvedDeviceInfo {
  final String name;

  const _ResolvedDeviceInfo({required this.name});
}
