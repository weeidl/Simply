import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  SplashCubit() : super(SplashState()) {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      print(user?.getIdToken());
      i(user);
      if (user == null) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated());
      }
    });
  }

  void i(User? user) async {
    final i = await user?.refreshToken;
    final i2 = await user?.getIdTokenResult();
    final i3 = await user?.uid;
    print(i);
    print(i2);
    print(i3);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
