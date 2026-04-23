import 'package:flutter_test/flutter_test.dart';
import 'package:simply/security/security_exceptions.dart';

void main() {
  test('keeps a user-friendly encryption unlock message', () {
    const exception = EncryptionUnlockFailedException(
      'This account was encrypted with a different password.',
    );

    expect(
      exception.userMessage,
      'This account was encrypted with a different password.',
    );
  });
}
