import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:simply/repositories/firebase_api.dart';
import 'package:simply/security/crypto_service.dart';
import 'package:simply/security/encryption_readiness.dart';
import 'package:simply/security/security_exceptions.dart';
import 'package:simply/security/key_envelope.dart';
import 'package:simply/security/secure_storage_service.dart';

class SecurityRepository {
  static final Map<String, List<int>> _memoryCache = {};

  final FirebaseApi _firebaseApi;
  final CryptoService _cryptoService;
  final SecureStorageService _secureStorageService;

  SecurityRepository({
    FirebaseApi? firebaseApi,
    CryptoService? cryptoService,
    SecureStorageService? secureStorageService,
  })  : _firebaseApi = firebaseApi ?? FirebaseApi(),
        _cryptoService = cryptoService ?? CryptoService(),
        _secureStorageService = secureStorageService ?? SecureStorageService();

  Future<void> unlockOrInitializeUser({
    required String uid,
    required String password,
  }) async {
    // Force the Firebase SDK to hydrate the freshly-signed-in auth token so
    // Firestore writes see an authenticated request. Without this, the first
    // write after sign-in can race and come through unauthenticated → rules
    // reject it as permission-denied.
    await _primeAuthToken(uid);

    final userData = await _runStep(
      'read users/$uid',
      () => _firebaseApi.getUserData(uid),
    );
    final security = _readSecurityMap(userData ?? const {});

    if (security == null || security['key_envelope'] == null) {
      await provisionUserSecurity(uid: uid, password: password);
      return;
    }

    final envelope = KeyEnvelope.fromJson(
      Map<String, dynamic>.from(
        security['key_envelope'] as Map<dynamic, dynamic>,
      ),
    );
    final masterKey = await _unwrapMasterKeyOrThrow(
      password: password,
      envelope: envelope,
    );

    await cacheMasterKey(uid: uid, masterKey: masterKey);
    await _runStep(
      'write users/$uid (last_unlocked_at)',
      () => _firebaseApi.setUserData(
        uid,
        {
          'security': {
            'is_enabled': true,
            'schema_version': 1,
            'last_unlocked_at': FieldValue.serverTimestamp(),
          },
        },
      ),
    );
  }

  Future<void> provisionUserSecurity({
    required String uid,
    required String password,
  }) async {
    await _primeAuthToken(uid);
    final generated = await _cryptoService.createMasterKeyEnvelope(
      password: password,
    );

    await _runStep(
      'write users/$uid (provision envelope)',
      () => _firebaseApi.setUserData(
        uid,
        {
          'security': {
            'is_enabled': true,
            'schema_version': 1,
            'key_envelope': generated.envelope.toJson(),
            'updated_at': FieldValue.serverTimestamp(),
          },
        },
      ),
    );
    await cacheMasterKey(uid: uid, masterKey: generated.masterKey);
  }

  Future<bool> canRestoreSession(String uid) async {
    final remoteEnvelopePresent = await hasRemoteEnvelope(uid: uid);
    final hasLocalMasterKey = (await readMasterKey(uid: uid)) != null;

    return EncryptionReadiness.isReady(
      hasRemoteEnvelope: remoteEnvelopePresent,
      hasLocalMasterKey: hasLocalMasterKey,
    );
  }

  Future<bool> isSecurityEnabled({String? uid}) async {
    return hasRemoteEnvelope(uid: uid);
  }

  Future<bool> hasRemoteEnvelope({String? uid}) async {
    final userId = uid ?? _firebaseApi.requireUserId();
    final userData = await _firebaseApi.getUserData(userId);
    final security = _readSecurityMap(userData);
    return security != null && security['key_envelope'] != null;
  }

  Future<void> cacheMasterKey({
    required String uid,
    required List<int> masterKey,
  }) async {
    final cachedKey = List<int>.unmodifiable(masterKey);
    _memoryCache[uid] = cachedKey;
    await _secureStorageService.writeMasterKey(uid, cachedKey);
  }

  Future<List<int>?> readMasterKey({String? uid}) async {
    final userId = uid ?? _firebaseApi.requireUserId();
    final cached = _memoryCache[userId];
    if (cached != null) return cached;

    final stored = await _secureStorageService.readMasterKey(userId);
    if (stored == null) return null;

    final cachedKey = List<int>.unmodifiable(stored);
    _memoryCache[userId] = cachedKey;
    return cachedKey;
  }

  Future<List<int>> requireMasterKey({String? uid}) async {
    final masterKey = await readMasterKey(uid: uid);
    if (masterKey == null) {
      throw StateError('Master key is not available.');
    }
    return masterKey;
  }

  Future<List<int>> requireEncryptionReady({String? uid}) async {
    final userId = uid ?? _firebaseApi.requireUserId();
    final remoteEnvelopePresent = await hasRemoteEnvelope(uid: userId);
    final masterKey = await readMasterKey(uid: userId);

    if (!EncryptionReadiness.isReady(
      hasRemoteEnvelope: remoteEnvelopePresent,
      hasLocalMasterKey: masterKey != null,
    )) {
      throw StateError(
        'Encryption is not initialized. Sign in again to enable encrypted storage.',
      );
    }

    return masterKey!;
  }

  Future<void> clearCachedSecrets(String uid) async {
    _memoryCache.remove(uid);
    await _secureStorageService.deleteMasterKey(uid);
  }

  Map<String, dynamic>? _readSecurityMap(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    final security = userData['security'];
    if (security is! Map) return null;
    return Map<String, dynamic>.from(security);
  }

  Future<void> _primeAuthToken(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != uid) return;
    try {
      await user.getIdToken();
    } catch (e, stack) {
      debugPrint('[SecurityRepository] getIdToken failed: $e\n$stack');
    }
  }

  Future<T> _runStep<T>(String step, Future<T> Function() op) async {
    try {
      return await op();
    } on FirebaseException catch (e, stack) {
      debugPrint('[SecurityRepository] step "$step" failed: '
          '${e.plugin}/${e.code} — ${e.message}\n$stack');
      rethrow;
    } catch (e, stack) {
      debugPrint('[SecurityRepository] step "$step" failed: $e\n$stack');
      rethrow;
    }
  }

  Future<List<int>> _unwrapMasterKeyOrThrow({
    required String password,
    required KeyEnvelope envelope,
  }) async {
    try {
      return await _cryptoService.unwrapMasterKey(
        password: password,
        envelope: envelope,
      );
    } on SecretBoxAuthenticationError {
      throw const EncryptionUnlockFailedException(
        'Encryption key does not match this password. This usually happens after a password reset.',
      );
    } on FormatException {
      throw const EncryptionUnlockFailedException(
        'Encrypted account data is damaged and could not be opened.',
      );
    }
  }
}
