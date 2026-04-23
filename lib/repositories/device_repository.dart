import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/device.dart';
import 'package:simply/models/device_sim_card.dart';
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
      {
        ...device.toMap(),
        'date_update_info': FieldValue.serverTimestamp(),
      },
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
    int? simCount,
    int? activeSimSlot,
    List<DeviceSimCard> simCards = const [],
    bool isMainDevice = false,
  }) async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);
    final currentDeviceRef = itemsBackend.doc(deviceId);
    final runtimePayload = {
      "battery_level": batteryStatus,
      "network_type": networkTypeStatus,
      "sim_count": simCount,
      "active_sim_slot": activeSimSlot,
      "sim_cards": simCards.map((item) => item.toMap()).toList(),
      "is_main_device": isMainDevice,
      "date_update_info": FieldValue.serverTimestamp(),
    };

    if (!isMainDevice) {
      await currentDeviceRef.set(
        runtimePayload,
        SetOptions(merge: true),
      );
      return;
    }

    final snapshot = await itemsBackend.get();
    final batch = _firebaseApi.firestore.batch();

    for (final device in snapshot.docs) {
      if (device.id == deviceId) continue;
      batch.set(
        device.reference,
        {
          "is_main_device": false,
          "date_update_info": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    batch.set(
      currentDeviceRef,
      runtimePayload,
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> delete(String deviceId) async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);
    await itemsBackend.doc(deviceId).delete();
  }

  Future<void> saveOrder(List<Device> devices) async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);
    final batch = _firebaseApi.firestore.batch();

    for (var i = 0; i < devices.length; i++) {
      final device = devices[i];
      batch.set(
        itemsBackend.doc(device.deviceId),
        {
          'sort_order': i,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}
