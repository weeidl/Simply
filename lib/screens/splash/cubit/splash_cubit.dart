import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  SplashCubit() : super(SplashState()) {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated());
      }
    });
  }

  Future<bool> signOut() async {
    try {
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
