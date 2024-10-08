import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit()
      : super(
          AuthState(
            status: AuthStatus.login,
            emailController: TextEditingController(),
            passwordController: TextEditingController(),
            nameController: TextEditingController(),
          ),
        );

  void setSegmentedControlState(AuthStatus status) {
    emit(state.copyWith(status: status));
  }

  Future<bool> signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: state.emailController.text,
        password: state.passwordController.text,
      );
      return true;
    } catch (e) {
      emit(state.copyWith(
          authErrorMessage: 'Failed to sign in: ${e.toString()}'));
      return false;
    }
  }

  Future<User?> signUp() async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: state.emailController.text,
        password: state.passwordController.text,
      );

      User? user = credential.user;
      if (user != null) {
        await user.updateDisplayName(state.nameController.text);
        await user.reload();
        return user;
      }
    } catch (e) {
      emit(state.copyWith(
          authErrorMessage: 'Failed to sign up: ${e.toString()}'));
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> close() {
    state.emailController.dispose();
    state.passwordController.dispose();
    state.nameController.dispose();
    return super.close();
  }
}
