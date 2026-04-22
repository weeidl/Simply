import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

final _emailRegex =
    RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$");

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(
          AuthState(
            status: AuthStatus.login,
            emailController: TextEditingController(),
            passwordController: TextEditingController(),
            nameController: TextEditingController(),
          ),
        );

  void setSegmentedControlState(AuthStatus status) {
    emit(state.copyWith(status: status, clearError: true));
  }

  String? _validate({required bool requireName}) {
    final email = state.emailController.text.trim();
    final password = state.passwordController.text;
    final name = state.nameController.text.trim();

    if (email.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(email)) return 'Enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (requireName && name.isEmpty) return 'Full name is required';
    return null;
  }

  Future<bool> signIn() async {
    final error = _validate(requireName: false);
    if (error != null) {
      emit(state.copyWith(authErrorMessage: error));
      return false;
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: state.emailController.text.trim(),
        password: state.passwordController.text,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(authErrorMessage: _mapAuthError(e)));
      return false;
    } catch (_) {
      emit(state.copyWith(authErrorMessage: 'Something went wrong'));
      return false;
    }
  }

  Future<User?> signUp() async {
    final error = _validate(requireName: true);
    if (error != null) {
      emit(state.copyWith(authErrorMessage: error));
      return null;
    }
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: state.emailController.text.trim(),
        password: state.passwordController.text,
      );

      final user = credential.user;
      if (user == null) return null;

      final name = state.nameController.text.trim();
      await user.updateDisplayName(name);
      await user.reload();

      await _firestore.collection('users').doc(user.uid).set(
        {
          'name': name,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(authErrorMessage: _mapAuthError(e)));
      return null;
    } catch (_) {
      emit(state.copyWith(authErrorMessage: 'Something went wrong'));
      return null;
    }
  }

  Future<bool> sendPasswordReset() async {
    final email = state.emailController.text.trim();
    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      emit(state.copyWith(
        authErrorMessage: 'Enter your email above first, then tap again',
      ));
      return false;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(authErrorMessage: _mapAuthError(e)));
      return false;
    }
  }

  Future<void> logout() => _auth.signOut();

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account is disabled';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password';
      case 'email-already-in-use':
        return 'Account with this email already exists';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  @override
  Future<void> close() {
    state.emailController.dispose();
    state.passwordController.dispose();
    state.nameController.dispose();
    return super.close();
  }
}
