import 'package:flutter_test/flutter_test.dart';
import 'package:simply/security/crypto_service.dart';
import 'package:simply/security/key_envelope.dart';

void main() {
  group('CryptoService', () {
    final cryptoService = CryptoService();

    test('creates and unwraps a master key with the same password', () async {
      final generated = await cryptoService.createMasterKeyEnvelope(
        password: 'correct horse battery staple',
      );

      final restored = await cryptoService.unwrapMasterKey(
        password: 'correct horse battery staple',
        envelope: generated.envelope,
      );

      expect(restored, generated.masterKey);
    });

    test('fails to unwrap a master key with a wrong password', () async {
      final generated = await cryptoService.createMasterKeyEnvelope(
        password: 'correct horse battery staple',
      );

      expect(
        () => cryptoService.unwrapMasterKey(
          password: 'wrong password',
          envelope: generated.envelope,
        ),
        throwsA(anything),
      );
    });

    test('encrypts and decrypts a string with the same master key', () async {
      final generated = await cryptoService.createMasterKeyEnvelope(
        password: 'correct horse battery staple',
      );

      final encrypted = await cryptoService.encryptString(
        plaintext: 'Secret SMS body',
        masterKey: generated.masterKey,
      );

      final decrypted = await cryptoService.decryptString(
        value: encrypted,
        masterKey: generated.masterKey,
      );

      expect(decrypted, 'Secret SMS body');
      expect(encrypted.cipherText, isNotEmpty);
      expect(encrypted.nonce, isNotEmpty);
      expect(encrypted.mac, isNotEmpty);
    });

    test('builds a deterministic obfuscated conversation id', () async {
      final generated = await cryptoService.createMasterKeyEnvelope(
        password: 'correct horse battery staple',
      );

      final first = cryptoService.conversationIdForSender(
        sender: '+381 60 123 45 67',
        masterKey: generated.masterKey,
      );
      final second = cryptoService.conversationIdForSender(
        sender: '+381 60 123 45 67',
        masterKey: generated.masterKey,
      );

      expect(first, second);
      expect(first, isNot(contains('+381')));
      expect(first.length, greaterThanOrEqualTo(32));
    });
  });

  group('KeyEnvelope', () {
    test('serializes to and from json', () {
      const envelope = KeyEnvelope(
        salt: 'salt',
        wrappedKey: EncryptedValue(
          cipherText: 'cipherText',
          nonce: 'nonce',
          mac: 'mac',
        ),
      );

      expect(KeyEnvelope.fromJson(envelope.toJson()), envelope);
    });
  });
}
