import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/bloc/notification/incoming_sms_sync_service.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/security/security_repository.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final FirebaseAuth _auth;
  final SecurityRepository _securityRepository;
  final MessagesRepository _messagesRepository;
  final IncomingSmsSyncService _incomingSmsSyncService;
  StreamSubscription<User?>? _authSubscription;

  SplashCubit({
    FirebaseAuth? auth,
    SecurityRepository? securityRepository,
    MessagesRepository? messagesRepository,
    IncomingSmsSyncService? incomingSmsSyncService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _securityRepository = securityRepository ?? SecurityRepository(),
        _messagesRepository = messagesRepository ?? MessagesRepository(),
        _incomingSmsSyncService =
            incomingSmsSyncService ?? IncomingSmsSyncService(),
        super(SplashState()) {
    _bootstrap();
  }

  /// Boot sequence:
  /// 1. If a user was already signed in when the app launched, check whether
  ///    their encryption state can be restored. If not — the local master
  ///    key was lost (app reinstall, device switch) and we can't decrypt the
  ///    cloud data, so force a sign-out to kick them back to the auth screen.
  /// 2. Then start listening to `authStateChanges` and mirror it into UI
  ///    state WITHOUT any side effects. The sign-in flow (`AuthCubit`)
  ///    handles its own envelope provisioning, so we must not race with it.
  Future<void> _bootstrap() async {
    final restoredUser = _auth.currentUser;
    if (restoredUser != null) {
      try {
        final canRestore = await _securityRepository.canRestoreSession(
          restoredUser.uid,
        );
        if (!canRestore) {
          await _auth.signOut();
        } else {
          try {
            await _messagesRepository.migrateLegacyDataIfNeeded();
            await _incomingSmsSyncService.flushPending();
          } catch (e, stack) {
            debugPrint('[SplashCubit] migration skipped: $e\n$stack');
          }
        }
      } catch (e, stack) {
        debugPrint('[SplashCubit] initial session check failed: $e\n$stack');
      }
    }

    _authSubscription = _auth.authStateChanges().listen((user) {
      emit(user == null ? AuthUnauthenticated() : AuthAuthenticated());
    });
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
    } catch (e, stack) {
      debugPrint('[SplashCubit] signOut failed: $e\n$stack');
      return false;
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
