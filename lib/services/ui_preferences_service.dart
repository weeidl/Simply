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
  static const _pinnedExpandedDeviceIdsKey =
      'ui.devices.pinned_expanded_ids';
  static const _savedLanguageKey = 'ui.locale.language_code';

  final FlutterSecureStorage _storage;

  UiPreferencesService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> isMessagesInfoBannerDismissed() async {
    return _readFlag(_messagesInfoBannerDismissedKey);
  }

  Future<void> setMessagesInfoBannerDismissed(bool dismissed) {
    return _writeFlag(_messagesInfoBannerDismissedKey, dismissed);
  }

  Future<Set<String>> readPinnedExpandedDeviceIds() async {
    final raw = await _storage.read(key: _pinnedExpandedDeviceIdsKey);
    if (raw == null || raw.isEmpty) return <String>{};
    return raw.split(',').where((value) => value.isNotEmpty).toSet();
  }

  Future<void> writePinnedExpandedDeviceIds(Set<String> ids) {
    return _storage.write(
      key: _pinnedExpandedDeviceIdsKey,
      value: ids.join(','),
    );
  }

  Future<bool> _readFlag(String key) async {
    final raw = await _storage.read(key: key);
    return raw == 'true';
  }

  Future<void> _writeFlag(String key, bool value) {
    return _storage.write(key: key, value: value ? 'true' : 'false');
  }

  Future<String?> readSavedLanguage() async {
    return _storage.read(key: _savedLanguageKey);
  }

  Future<void> saveSavedLanguage(String languageCode) {
    return _storage.write(key: _savedLanguageKey, value: languageCode);
  }
}
