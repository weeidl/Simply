import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_forward_app/models/device.dart';
import 'package:sms_forward_app/repositories/device_repository.dart';
import 'package:telephony/telephony.dart';

part 'check_device_state.dart';

class CheckDeviceCubit extends Cubit<CheckDeviceState> {
  final DeviceRepository _deviceRepository = DeviceRepository();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  CheckDeviceCubit() : super(CheckDeviceState());

  Future checkDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isNewDevice = prefs.getBool('is_new_device');

    if (isNewDevice == null || isNewDevice) {
      await setBaseInfoForDevice();

      if (Platform.isIOS) return;

      // Проверить есть ли is_new_device в фаербейс, если нет то выводим модалку
      // если маин девайс есть но нет сети и зарядки выводить кнопку включить дисплей нетворк и зарядки

      await prefs.setBool('is_new_device', false);
      emit(state.copyWith(status: DeviceSettingStatus.showModal));
    }
  }

  Future<void> saveSettingDevice({
    required bool isSMSEnabled,
    required bool isNetworkEnabled,
    required bool isChargingEnabled,
    String? deviceId,
  }) async {
    AndroidDeviceInfo device = await deviceInfo.androidInfo;

    int? batteryLevel;
    String? network;

    if (isChargingEnabled) {
      var battery = Battery();
      batteryLevel = await battery.batteryLevel;
    }

    if (isNetworkEnabled) {
      final Telephony telephony = Telephony.instance;
      final NetworkType networkType = await telephony.dataNetworkType;
      network = networkType.name;
    }

    _deviceRepository.addBatteryAndNetworkStatus(
      isMainDevice: isSMSEnabled,
      batteryStatus: batteryLevel,
      networkTypeStatus: network,
      deviceId: deviceId ?? device.id,
    );
  }

  Future<void> setBaseInfoForDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final String id;
    final String name;

    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      id = iosDeviceInfo.identifierForVendor ?? '';
      name = iosDeviceInfo.name;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
      name = androidInfo.model;
    }

    _deviceRepository.update(
      device: Device(
        userId: _deviceRepository.id,
        deviceId: id,
        deviceName: name,
      ),
    );
  }
}
