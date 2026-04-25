part of 'profile_cubit.dart';

enum ProfileErrorCode { nameEmpty, sessionExpired, saveFailed }

@immutable
class ProfileState {
  final String displayName;
  final String email;
  final DateTime? memberSince;
  final bool isSaving;
  final ProfileErrorCode? errorCode;

  const ProfileState({
    required this.displayName,
    required this.email,
    required this.memberSince,
    required this.isSaving,
    required this.errorCode,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      displayName: '',
      email: '',
      memberSince: null,
      isSaving: false,
      errorCode: null,
    );
  }

  ProfileState copyWith({
    String? displayName,
    String? email,
    DateTime? memberSince,
    bool? isSaving,
    ProfileErrorCode? errorCode,
    bool clearError = false,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      memberSince: memberSince ?? this.memberSince,
      isSaving: isSaving ?? this.isSaving,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}
