import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:simply/security/key_envelope.dart';

class GeneratedMasterKey {
  final List<int> masterKey;
  final KeyEnvelope envelope;

  GeneratedMasterKey({
    required this.masterKey,
    required this.envelope,
  });
}

class CryptoService {
  static const _masterKeyLength = 32;
  static const _saltLength = 16;
  static const _pbkdf2Iterations = 120000;

  final AesGcm _cipher;
  final Hmac _hmac;

  CryptoService({
    AesGcm? cipher,
    Hmac? hmac,
  })  : _cipher = cipher ?? AesGcm.with256bits(),
        _hmac = hmac ?? Hmac.sha256();

  Future<GeneratedMasterKey> createMasterKeyEnvelope({
    required String password,
  }) async {
    final secretKey = await _cipher.newSecretKey();
    final masterKey = await secretKey.extractBytes();
    final salt = SecretKeyData.random(length: _saltLength).bytes;
    final wrappingKey = await _deriveWrappingKey(password, salt);
    final wrappedKey = await _encryptBytes(
      bytes: masterKey,
      secretKeyBytes: wrappingKey,
    );

    return GeneratedMasterKey(
      masterKey: masterKey,
      envelope: KeyEnvelope(
        salt: base64Encode(salt),
        wrappedKey: wrappedKey,
      ),
    );
  }

  Future<List<int>> unwrapMasterKey({
    required String password,
    required KeyEnvelope envelope,
  }) async {
    final salt = base64Decode(envelope.salt);
    final wrappingKey = await _deriveWrappingKey(
      password,
      salt,
      iterations: envelope.iterations,
    );

    return _decryptBytes(
      value: envelope.wrappedKey,
      secretKeyBytes: wrappingKey,
    );
  }

  Future<EncryptedValue> encryptString({
    required String plaintext,
    required List<int> masterKey,
  }) async {
    return _encryptBytes(
      bytes: utf8.encode(plaintext),
      secretKeyBytes: masterKey,
    );
  }

  Future<String> decryptString({
    required EncryptedValue value,
    required List<int> masterKey,
  }) async {
    final bytes = await _decryptBytes(
      value: value,
      secretKeyBytes: masterKey,
    );
    return utf8.decode(bytes);
  }

  String conversationIdForSender({
    required String sender,
    required List<int> masterKey,
  }) {
    final normalizedSender = _normalizeSender(sender);
    final mac = _hmac.toSync().calculateMacSync(
      utf8.encode(normalizedSender),
      secretKeyData: SecretKeyData(masterKey),
      nonce: const [],
    );
    final digest = mac.bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'conv_${digest.substring(0, 32)}';
  }

  Future<List<int>> _deriveWrappingKey(
    String password,
    List<int> salt, {
    int iterations = _pbkdf2Iterations,
  }) async {
    final derivedKey = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: _masterKeyLength * 8,
    ).deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return derivedKey.extractBytes();
  }

  Future<EncryptedValue> _encryptBytes({
    required List<int> bytes,
    required List<int> secretKeyBytes,
  }) async {
    final secretBox = await _cipher.encrypt(
      bytes,
      secretKey: SecretKey(secretKeyBytes),
    );

    return EncryptedValue(
      cipherText: base64Encode(secretBox.cipherText),
      nonce: base64Encode(secretBox.nonce),
      mac: base64Encode(secretBox.mac.bytes),
    );
  }

  Future<List<int>> _decryptBytes({
    required EncryptedValue value,
    required List<int> secretKeyBytes,
  }) {
    final secretBox = SecretBox(
      base64Decode(value.cipherText),
      nonce: base64Decode(value.nonce),
      mac: Mac(base64Decode(value.mac)),
    );

    return _cipher.decrypt(
      secretBox,
      secretKey: SecretKey(secretKeyBytes),
    );
  }

  String _normalizeSender(String sender) {
    return sender.trim().replaceAll(RegExp(r'\s+'), '');
  }
}
