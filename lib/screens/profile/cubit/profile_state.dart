part of 'profile_cubit.dart';

@immutable
class ProfileState {
  final String displayName;
  final String email;
  final DateTime? memberSince;
  final bool isSaving;
  final String? errorMessage;

  const ProfileState({
    required this.displayName,
    required this.email,
    required this.memberSince,
    required this.isSaving,
    required this.errorMessage,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      displayName: '',
      email: '',
      memberSince: null,
      isSaving: false,
      errorMessage: null,
    );
  }

  ProfileState copyWith({
    String? displayName,
    String? email,
    DateTime? memberSince,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      memberSince: memberSince ?? this.memberSince,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
