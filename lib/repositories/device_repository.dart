import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_forward_app/models/device.dart';
import 'package:sms_forward_app/repositories/firebase_api.dart';

class DeviceRepository {
  final FirebaseApi _firebaseApi = FirebaseApi();
  static const _url = "devices";

  String get id => _firebaseApi.userId ?? '';

  Future<void> update(
      {required Device device, required String deviceID}) async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);

    await itemsBackend.doc(deviceID).set(
          device.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<List<String>> getTokensForAllDevices(String userId) async {
    try {
      final CollectionReference<Map<String, dynamic>> collectionReference =
          _firebaseApi.itemsCollection(_url);

      final querySnapshot = await collectionReference.get();

      final List<String> tokens = [];

      for (var document in querySnapshot.docs) {
        final deviceData = document.data();
        final token = deviceData['token'] as String;

        tokens.add(token);
      }

      return tokens;
    } catch (e) {
      print("Произошла ошибка при получении токенов устройств: $e");
      return [];
    }
  }

  Future<List<Device>> fetch() async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);
    final snapshot = await itemsBackend.get();

    List<Device> device = snapshot.docs.map((doc) {
      return Device.fromMap(doc.data());
    }).toList();

    return device;
  }

  Future<void> addBatteryAndNetworkStatus({
    required String deviceId,
    required int batteryStatus,
    required String networkTypeStatus,
  }) async {
    final itemsBackend = _firebaseApi.itemsCollection(_url);

    await itemsBackend.doc(deviceId).set(
      {
        "battery_level": batteryStatus,
        "network_type": networkTypeStatus,
        "date_update_info": DateTime.now(),
      },
      SetOptions(merge: true),
    );
  }
}
