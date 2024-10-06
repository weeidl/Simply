import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String userId;
  final String token;
  final String deviceName;
  final String deviceId;
  final bool? isMainDevice;
  final int? batteryLevel;
  final String? networkType;
  final Timestamp? dateUpdateInfo;

  Device({
    required this.userId,
    required this.token,
    required this.deviceName,
    required this.deviceId,
    this.isMainDevice,
    this.batteryLevel,
    this.networkType,
    this.dateUpdateInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      'token': token,
      'device_name': deviceName,
      'device_id': deviceId,
      'battery_level': batteryLevel,
      "is_main_device": isMainDevice,
      "network_type": networkType,
      "date_update_info": dateUpdateInfo,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      userId: map['user_id'],
      token: map['token'],
      deviceName: map['device_name'],
      deviceId: map['device_id'],
      isMainDevice: map['is_main_device'],
      batteryLevel: map['battery_level'],
      networkType: map['network_type'],
      dateUpdateInfo: map['date_update_info'],
    );
  }
}
