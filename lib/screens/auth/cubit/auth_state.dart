part of 'auth_cubit.dart';

enum AuthStatus { login, register }

class AuthState {
  final AuthStatus status;
  final String? authErrorMessage;

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;

  AuthState({
    required this.status,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    this.authErrorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? authErrorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      emailController: emailController,
      passwordController: passwordController,
      nameController: nameController,
      authErrorMessage:
          clearError ? null : (authErrorMessage ?? this.authErrorMessage),
    );
  }
}
