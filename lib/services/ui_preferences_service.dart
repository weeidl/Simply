import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin key/value store for non-sensitive UI preferences (banner dismissal,
/// onboarding flags, …). Backed by `flutter_secure_storage` so we don't add
/// another persistence dependency — the trade-off is a slower async read,
/// which is fine because callers only touch it on screen mount.
///
/// Kept separate from [SecureStorageService] so security-sensitive data
/// (master keys, device ids) doesn't share a class with ephemeral UI flags.
class UiPreferencesService {
  static const _messagesInfoBannerDismissedKey =
      'ui.banner.messages_info.dismissed';

  final FlutterSecureStorage _storage;

  UiPreferencesService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> isMessagesInfoBannerDismissed() async {
    return _readFlag(_messagesInfoBannerDismissedKey);
  }

  Future<void> setMessagesInfoBannerDismissed(bool dismissed) {
    return _writeFlag(_messagesInfoBannerDismissedKey, dismissed);
  }

  Future<bool> _readFlag(String key) async {
    final raw = await _storage.read(key: key);
    return raw == 'true';
  }

  Future<void> _writeFlag(String key, bool value) {
    return _storage.write(key: key, value: value ? 'true' : 'false');
  }
}
