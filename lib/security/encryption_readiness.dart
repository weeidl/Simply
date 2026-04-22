class EncryptionReadiness {
  static bool isReady({
    required bool hasRemoteEnvelope,
    required bool hasLocalMasterKey,
  }) {
    return hasRemoteEnvelope && hasLocalMasterKey;
  }
}
