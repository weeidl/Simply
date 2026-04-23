import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:simply/screens/auth/cubit/auth_cubit.dart';
import 'package:simply/screens/auth/widget/custom_segmented_control.dart';
import 'package:simply/screens/auth/widget/custom_text_field.dart';
import 'package:simply/screens/home/home.dart';
import 'package:simply/screens/widget/dialogs/message_dialog.dart';
import 'package:simply/screens/widget/divider_with_text.dart';
import 'package:simply/screens/widget/sign_in_button.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => AuthCubit(),
        child: const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.bg,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final isLogin = state.status == AuthStatus.login;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(24),
                  Text(
                    isLogin ? 'Привет!' : 'Создать аккаунт',
                    style: AppTextStyle.display(AppColor.ink),
                  ),
                  const Gap(8),
                  Text(
                    isLogin
                        ? 'Войдите, чтобы продолжить пересылку SMS'
                        : 'Несколько секунд — и вы в Simply',
                    style: AppTextStyle.bodyM(AppColor.inkSecondary),
                  ),
                  const Gap(28),
                  Expanded(child: _buildForm(context, cubit, state, isLogin)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AuthCubit cubit,
    AuthState state,
    bool isLogin,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: AppRadii.brR4,
        boxShadow: AppShadows.s,
        border: Border.all(color: const Color(0x0A281910)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomSegmentedControl(
              groupValue: state.status,
              onValueChanged: cubit.setSegmentedControlState,
              children: {
                AuthStatus.login: Text(
                  'Вход',
                  style: AppTextStyle.bodySmBold(
                    isLogin ? AppColor.ink : AppColor.inkTertiary,
                  ),
                ),
                AuthStatus.register: Text(
                  'Регистрация',
                  style: AppTextStyle.bodySmBold(
                    !isLogin ? AppColor.ink : AppColor.inkTertiary,
                  ),
                ),
              },
            ),
            const Gap(20),
            if (!isLogin) ...[
              CustomTextField(
                controller: state.nameController,
                labelText: 'Имя',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const Gap(10),
            ],
            CustomTextField(
              controller: state.emailController,
              labelText: 'E-mail',
              prefixIcon: Icons.mail_outline_rounded,
            ),
            const Gap(10),
            CustomTextField(
              controller: state.passwordController,
              labelText: 'Пароль',
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
            ),
            if (isLogin) ...[
              const Gap(10),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  borderRadius: AppRadii.brR1,
                  onTap: () => _sendPasswordReset(context, cubit),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Text(
                      'Забыли пароль?',
                      style: AppTextStyle.bodySmBold(AppColor.accentDeep),
                    ),
                  ),
                ),
              ),
            ],
            const Gap(20),
            _PrimaryButton(
              label: isLogin ? 'Войти' : 'Создать аккаунт',
              onTap: () => _submit(context, cubit, state),
            ),
            const Gap(20),
            const DividerWithText(text: 'или через'),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: SignInButton(
                    text: 'Google',
                    assetName: 'assets/icons/login_google.png',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SignInButton(
                    text: 'Apple',
                    assetName: 'assets/icons/login_apple.png',
                    onPressed: () {},
                    backgroundColor: AppColor.ink,
                    textColor: AppColor.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset(BuildContext context, AuthCubit cubit) async {
    final ok = await cubit.sendPasswordReset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Ссылка для сброса пароля отправлена'
              : cubit.state.authErrorMessage ??
                  'Не удалось отправить письмо',
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    AuthCubit cubit,
    AuthState state,
  ) async {
    final isLogin = state.status == AuthStatus.login;
    if (isLogin) {
      final success = await cubit.signIn();
      if (!success) {
        if (!context.mounted) return;
        await MessageDialog.show(
          context: context,
          text: cubit.state.authErrorMessage ?? 'Не удалось войти',
          buttonText: 'OK',
        );
        return;
      }
    } else {
      final user = await cubit.signUp();
      if (user == null) {
        if (!context.mounted) return;
        await MessageDialog.show(
          context: context,
          text: cubit.state.authErrorMessage ?? 'Не удалось создать аккаунт',
          buttonText: 'OK',
        );
        return;
      }
    }

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(context, HomePage.route(), (_) => false);
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.accent,
          foregroundColor: AppColor.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brPill),
        ),
        child: Text(label, style: AppTextStyle.button(AppColor.white)),
      ),
    );
  }
}
