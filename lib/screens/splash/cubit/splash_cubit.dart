import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/security/security_repository.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final FirebaseAuth _auth;
  final SecurityRepository _securityRepository;
  final MessagesRepository _messagesRepository;
  StreamSubscription<User?>? _authSubscription;

  SplashCubit({
    FirebaseAuth? auth,
    SecurityRepository? securityRepository,
    MessagesRepository? messagesRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _securityRepository = securityRepository ?? SecurityRepository(),
        _messagesRepository = messagesRepository ?? MessagesRepository(),
        super(SplashState()) {
    _authSubscription = _auth.authStateChanges().listen(_handleAuthState);
  }

  Future<void> _handleAuthState(User? user) async {
    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }

    final canRestoreSession = await _securityRepository.canRestoreSession(
      user.uid,
    );
    if (!canRestoreSession) {
      await _auth.signOut();
      return;
    }

    try {
      await _messagesRepository.migrateLegacyDataIfNeeded();
    } catch (_) {
      // Best-effort migration on restored sessions. New writes are blocked
      // unless encryption is ready, so a failed migration won't leak plaintext.
    }

    emit(AuthAuthenticated());
  }

  Future<bool> signOut() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _securityRepository.clearCachedSecrets(uid);
      }
      await _auth.signOut();
      emit(AuthUnauthenticated());
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
