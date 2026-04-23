import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/security/security_exceptions.dart';
import 'package:simply/security/security_repository.dart';

part 'auth_state.dart';

final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$");

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SecurityRepository _securityRepository;
  final MessagesRepository _messagesRepository;

  AuthCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SecurityRepository? securityRepository,
    MessagesRepository? messagesRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _securityRepository = securityRepository ?? SecurityRepository(),
        _messagesRepository = messagesRepository ?? MessagesRepository(),
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

    final User user;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: state.emailController.text.trim(),
        password: state.passwordController.text,
      );
      final signedInUser = credential.user;
      if (signedInUser == null) {
        throw StateError('User is missing after sign-in.');
      }
      user = signedInUser;
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(authErrorMessage: _mapAuthError(e)));
      return false;
    } catch (e, stack) {
      debugPrint('[AuthCubit.signIn] unexpected: $e\n$stack');
      emit(state.copyWith(
          authErrorMessage: 'Sign-in failed: ${_describe(e)}'));
      return false;
    }

    try {
      await _securityRepository.unlockOrInitializeUser(
        uid: user.uid,
        password: state.passwordController.text,
      );
    } on EncryptionUnlockFailedException catch (e) {
      // Wrong password for existing envelope — auth session is safe to kill.
      await _auth.signOut();
      emit(state.copyWith(authErrorMessage: e.userMessage));
      return false;
    } on FirebaseException catch (e, stack) {
      debugPrint('[AuthCubit.signIn] firestore during unlock: ${e.code} '
          '${e.message}\n$stack');
      emit(state.copyWith(authErrorMessage: _mapFirestoreError(e)));
      return false;
    } catch (e, stack) {
      debugPrint('[AuthCubit.signIn] unlock failed: $e\n$stack');
      emit(state.copyWith(
          authErrorMessage: 'Could not unlock account: ${_describe(e)}'));
      return false;
    }

    // Best-effort: legacy-data migration should never block login.
    try {
      await _messagesRepository.migrateLegacyDataIfNeeded();
    } catch (e, stack) {
      debugPrint('[AuthCubit.signIn] migration skipped: $e\n$stack');
    }

    return true;
  }

  Future<User?> signUp() async {
    final error = _validate(requireName: true);
    if (error != null) {
      emit(state.copyWith(authErrorMessage: error));
      return null;
    }

    final User user;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: state.emailController.text.trim(),
        password: state.passwordController.text,
      );
      final created = credential.user;
      if (created == null) {
        throw StateError('User is missing after sign-up.');
      }
      user = created;
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(authErrorMessage: _mapAuthError(e)));
      return null;
    } catch (e, stack) {
      debugPrint('[AuthCubit.signUp] unexpected: $e\n$stack');
      emit(state.copyWith(
          authErrorMessage: 'Sign-up failed: ${_describe(e)}'));
      return null;
    }

    try {
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

      await _securityRepository.provisionUserSecurity(
        uid: user.uid,
        password: state.passwordController.text,
      );
    } on FirebaseException catch (e, stack) {
      debugPrint('[AuthCubit.signUp] firestore after create: ${e.code} '
          '${e.message}\n$stack');
      emit(state.copyWith(authErrorMessage: _mapFirestoreError(e)));
      return null;
    } catch (e, stack) {
      debugPrint('[AuthCubit.signUp] post-create failed: $e\n$stack');
      emit(state.copyWith(
          authErrorMessage: 'Account created, setup failed: ${_describe(e)}'));
      return null;
    }

    return _auth.currentUser;
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

  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _securityRepository.clearCachedSecrets(uid);
    }
    await _auth.signOut();
  }

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

  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Access denied. Check that your account is configured '
            'correctly.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Network error. Check your connection and try again.';
      case 'unauthenticated':
        return 'Session expired. Sign in again.';
      default:
        return 'Database error: ${e.code}';
    }
  }

  String _describe(Object error) {
    final text = error.toString();
    return text.length > 120 ? '${text.substring(0, 117)}…' : text;
  }

  @override
  Future<void> close() {
    state.emailController.dispose();
    state.passwordController.dispose();
    state.nameController.dispose();
    return super.close();
  }
}
