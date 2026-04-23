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
    return writeValue(
      '$_masterKeyPrefix$userId',
      base64Encode(masterKey),
    );
  }

  Future<List<int>?> readMasterKey(String userId) async {
    final encoded = await readValue('$_masterKeyPrefix$userId');
    if (encoded == null || encoded.isEmpty) return null;
    return base64Decode(encoded);
  }

  Future<void> deleteMasterKey(String userId) {
    return deleteValue('$_masterKeyPrefix$userId');
  }

  Future<void> writeDeviceId(String deviceId) {
    return writeValue(_deviceIdKey, deviceId);
  }

  Future<String?> readDeviceId() {
    return readValue(_deviceIdKey);
  }

  Future<void> writeValue(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<String?> readValue(String key) {
    return _storage.read(key: key);
  }

  Future<void> deleteValue(String key) {
    return _storage.delete(key: key);
  }
}
