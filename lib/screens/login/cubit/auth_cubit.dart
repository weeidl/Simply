import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit() : super(AuthInit()) {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        emitAuthUnauthenticated();
      } else {
        emit(AuthAuthenticated());
      }
    });
  }

  void checkAuthState() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        emitAuthUnauthenticated();
      } else {
        emit(AuthAuthenticated());
      }
    });
  }

  void emitAuthUnauthenticated() {
    emit(
      AuthUnauthenticated(
        status: AuthStatus.login,
        emailController: TextEditingController(),
        passwordController: TextEditingController(),
        nameController: TextEditingController(),
        authErrorMessage: null,
      ),
    );
  }

  void setSegmentedControlState(AuthStatus status) {
    if (state is AuthUnauthenticated) {
      final unAuthState = state as AuthUnauthenticated;
      emit(unAuthState.copyWith(status: status));
    }
  }

  bool validateFields() {
    if (state is AuthUnauthenticated) {
      final unAuthState = state as AuthUnauthenticated;

      String? emailError;
      String? passwordError;
      String? nameError;

      bool isValid = true;

      if (!_isValidEmail(unAuthState.emailController.text)) {
        emailError = 'Enter a valid email';
        isValid = false;
      }

      if (!_isValidPassword(unAuthState.passwordController.text)) {
        passwordError = 'Password must be at least 6 characters';
        isValid = false;
      }

      if (unAuthState.status == AuthStatus.register &&
          unAuthState.nameController.text.isEmpty) {
        nameError = 'Enter your name';
        isValid = false;
      }

      emit(
        unAuthState.copyWith(
          authErrorMessage: _buildErrorMessage(
            emailError: emailError,
            passwordError: passwordError,
            nameError: nameError,
          ),
        ),
      );

      return isValid;
    }

    return false;
  }

  Future<bool> signIn() async {
    if (state is AuthUnauthenticated) {
      final unAuthState = state as AuthUnauthenticated;

      if (!validateFields()) return false;

      try {
        await _auth.signInWithEmailAndPassword(
          email: unAuthState.emailController.text,
          password: unAuthState.passwordController.text,
        );
        emit(unAuthState.copyWith(authErrorMessage: null));
        return true;
      } catch (e) {
        emit(unAuthState.copyWith(
            authErrorMessage: 'Failed to sign in: ${e.toString()}'));
        return false;
      }
    }
    return false;
  }

  Future<User?> signUp() async {
    if (state is AuthUnauthenticated) {
      final unAuthState = state as AuthUnauthenticated;

      if (!validateFields()) return null;

      try {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: unAuthState.emailController.text,
          password: unAuthState.passwordController.text,
        );

        User? user = credential.user;

        if (user != null) {
          await user.updateDisplayName(unAuthState.nameController.text);
          await user.reload();
          emit(unAuthState.copyWith(authErrorMessage: null));
          return user;
        }
      } catch (e) {
        emit(unAuthState.copyWith(
            authErrorMessage: 'Failed to sign up: ${e.toString()}'));
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
    emitAuthUnauthenticated();
  }

  @override
  Future<void> close() {
    if (state is AuthUnauthenticated) {
      final unAuthState = state as AuthUnauthenticated;
      unAuthState.emailController.dispose();
      unAuthState.passwordController.dispose();
      unAuthState.nameController.dispose();
    }
    _authSubscription?.cancel();
    return super.close();
  }

  bool _isValidEmail(String email) {
    return email.isNotEmpty && email.contains('@');
  }

  bool _isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  String _buildErrorMessage(
      {String? emailError, String? passwordError, String? nameError}) {
    List<String> errors = [];
    if (emailError != null) errors.add(emailError);
    if (passwordError != null) errors.add(passwordError);
    if (nameError != null) errors.add(nameError);
    return errors.join('\n');
  }
}
