class EncryptionUnlockFailedException implements Exception {
  final String userMessage;

  const EncryptionUnlockFailedException(this.userMessage);
}
