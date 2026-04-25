import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(ProfileState.initial()) {
    _hydrate();
  }

  void _hydrate() {
    final user = _auth.currentUser;
    emit(state.copyWith(
      displayName: user?.displayName ?? '',
      email: user?.email ?? '',
      memberSince: user?.metadata.creationTime,
    ));
  }

  Future<bool> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(errorCode: ProfileErrorCode.nameEmpty));
      return false;
    }
    if (trimmed == state.displayName.trim()) {
      return true;
    }
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(errorCode: ProfileErrorCode.sessionExpired));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await user.updateDisplayName(trimmed);
      await user.reload();
      await _firestore.collection('users').doc(user.uid).set(
        {'name': trimmed},
        SetOptions(merge: true),
      );
      emit(state.copyWith(displayName: trimmed, isSaving: false));
      return true;
    } catch (e, stack) {
      debugPrint('[ProfileCubit.updateDisplayName] $e\n$stack');
      emit(state.copyWith(
        isSaving: false,
        errorCode: ProfileErrorCode.saveFailed,
      ));
      return false;
    }
  }
}
