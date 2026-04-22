import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _deviceIdKey = 'device.stable_id';
  static const _masterKeyPrefix = 'security.master_key.';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  Future<void> writeMasterKey(String userId, List<int> masterKey) {
    return _storage.write(
      key: '$_masterKeyPrefix$userId',
      value: base64Encode(masterKey),
    );
  }

  Future<List<int>?> readMasterKey(String userId) async {
    final encoded = await _storage.read(key: '$_masterKeyPrefix$userId');
    if (encoded == null || encoded.isEmpty) return null;
    return base64Decode(encoded);
  }

  Future<void> deleteMasterKey(String userId) {
    return _storage.delete(key: '$_masterKeyPrefix$userId');
  }

  Future<void> writeDeviceId(String deviceId) {
    return _storage.write(key: _deviceIdKey, value: deviceId);
  }

  Future<String?> readDeviceId() {
    return _storage.read(key: _deviceIdKey);
  }
}
