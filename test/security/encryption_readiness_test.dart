import 'package:flutter_test/flutter_test.dart';
import 'package:simply/security/encryption_readiness.dart';

void main() {
  group('EncryptionReadiness', () {
    test('is not ready without a remote envelope', () {
      expect(
        EncryptionReadiness.isReady(
          hasRemoteEnvelope: false,
          hasLocalMasterKey: true,
        ),
        isFalse,
      );
    });

    test('is not ready without a local master key', () {
      expect(
        EncryptionReadiness.isReady(
          hasRemoteEnvelope: true,
          hasLocalMasterKey: false,
        ),
        isFalse,
      );
    });

    test('is ready only when both remote and local pieces exist', () {
      expect(
        EncryptionReadiness.isReady(
          hasRemoteEnvelope: true,
          hasLocalMasterKey: true,
        ),
        isTrue,
      );
    });
  });
}
