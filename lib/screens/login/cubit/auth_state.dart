part of 'auth_cubit.dart';

enum AuthStatus { login, register }

@immutable
abstract class AuthState {}

class AuthInit extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {
  final AuthStatus status;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final String? authErrorMessage;

  AuthUnauthenticated({
    required this.status,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    this.authErrorMessage,
  });

  AuthUnauthenticated copyWith({
    AuthStatus? status,
    String? authErrorMessage,
  }) {
    return AuthUnauthenticated(
      status: status ?? this.status,
      emailController: emailController,
      passwordController: passwordController,
      nameController: nameController,
      authErrorMessage: authErrorMessage,
    );
  }
}
