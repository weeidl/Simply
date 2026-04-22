import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/device.dart';
import 'package:simply/repositories/firebase_api.dart';

class DeviceRepository {
  final FirebaseApi _firebaseApi;
  static const _url = "devices";

  DeviceRepository({FirebaseApi? firebaseApi})
      : _firebaseApi = firebaseApi ?? FirebaseApi();

  String get id => _firebaseApi.userId ?? '';

  Future<void> update({required Device device}) async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);

    await itemsBackend.doc(device.deviceId).set(
          device.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<List<String>> getTokensForCurrentUser() async {
    try {
      final collectionReference = _firebaseApi.itemsCollection(_url);
      final querySnapshot = await collectionReference.get();

      return querySnapshot.docs
          .map((doc) => doc.data()['token'] as String?)
          .whereType<String>()
          .toList();
    } catch (e) {
      log('Failed to fetch device tokens: $e');
      return [];
    }
  }

  Future<List<Device>> fetch() async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);
    final snapshot = await itemsBackend.get();

    return snapshot.docs.map((doc) => Device.fromMap(doc.data())).toList();
  }

  Future<void> addBatteryAndNetworkStatus({
    required String deviceId,
    int? batteryStatus,
    String? networkTypeStatus,
    bool isMainDevice = false,
  }) async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);

    await itemsBackend.doc(deviceId).set(
      {
        "battery_level": batteryStatus,
        "network_type": networkTypeStatus,
        "is_main_device": isMainDevice,
        "date_update_info": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> delete(String deviceId) async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);
    await itemsBackend.doc(deviceId).delete();
  }
}
