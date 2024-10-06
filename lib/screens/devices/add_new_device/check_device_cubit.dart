import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_forward_app/models/device.dart';
import 'package:sms_forward_app/repositories/device_repository.dart';
import 'package:telephony/telephony.dart';

part 'check_device_state.dart';

class CheckDeviceCubit extends Cubit<CheckDeviceState> {
  final DeviceRepository _deviceRepository = DeviceRepository();

  CheckDeviceCubit() : super(CheckDeviceState());

  Future checkDevice() async {
    updateInfoMainDevice();
    final isNewDevice = await checkDeviceTokenToPreferences();

    // if (isNewDevice) {
    await FirebaseMessaging.instance.getToken().then((token) async {
      saveDevice(token!);
    });
    // }

    Timer.periodic(const Duration(minutes: 1), (Timer t) {
      updateInfoMainDevice();
    });
  }

  Future<void> saveDevice(String token) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final isMainDevice = await checkMainDevice();
    final String id;
    final String model;

    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      id = iosDeviceInfo.identifierForVendor ?? '';
      model = iosDeviceInfo.name;
    } else {
      saveDeviceTokenToPreferences(token);
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
      model = androidInfo.model;
    }

    _deviceRepository.update(
      deviceID: id,
      device: Device(
        token: token,
        deviceId: id,
        userId: _deviceRepository.id,
        deviceName: model,
        isMainDevice: isMainDevice,
      ),
    );
  }

  Future updateInfoMainDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? device = prefs.getBool('is_main_device');
    if (device ?? false) {
      // updateInfoDevice();
    }
  }

  // void updateInfoDevice() async {
  //   var battery = Battery();
  //   int batteryLevel = await battery.batteryLevel;
  //
  //   final Telephony telephony = Telephony.instance;
  //   final NetworkType networkType = await telephony.dataNetworkType;
  //
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //
  //   _deviceRepository.addBatteryAndNetworkStatus(
  //     batteryStatus: batteryLevel,
  //     networkTypeStatus: networkType.name,
  //     deviceId: androidInfo.id,
  //   );
  // }

  Future<void> saveDeviceTokenToPreferences(String? token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_token', token ?? '');
  }

  Future<void> saveMainDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_main_device', true);
  }

  Future<bool?> checkMainDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? device = prefs.getBool('is_main_device');
    return device;
  }

  Future<bool> checkDeviceTokenToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final device = prefs.get('device_token');
    final bool isNewDevice = device == null;
    return isNewDevice;
  }
}
