import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:simply/screens/auth/cubit/auth_cubit.dart';
import 'package:simply/screens/auth/widget/custom_segmented_control.dart';
import 'package:simply/screens/auth/widget/custom_text_field.dart';
import 'package:simply/screens/home/home.dart';
import 'package:simply/screens/widget/dialogs/message_dialog.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/screens/widget/warm/warm_loader.dart';
import 'package:simply/screens/widget/warm/warm_toast.dart';
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  _buildForm(context, cubit, state, isLogin),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                onTap: state.isResetSending
                    ? null
                    : () => _sendPasswordReset(context, cubit),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.isResetSending) ...[
                        const WarmLoader(size: 12, strokeWidth: 2),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        'Забыли пароль?',
                        style: AppTextStyle.bodySmBold(AppColor.accentDeep),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const Gap(20),
          _PrimaryButton(
            label: isLogin ? 'Войти' : 'Создать аккаунт',
            loading: state.isSubmitting,
            onTap: () => _submit(context, cubit, state),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordReset(BuildContext context, AuthCubit cubit) async {
    final ok = await cubit.sendPasswordReset();
    if (!context.mounted) return;
    if (ok) {
      WarmToast.success(
        context,
        'Ссылка для сброса пароля отправлена',
        icon: Icons.mark_email_read_rounded,
      );
    } else {
      WarmToast.error(
        context,
        cubit.state.authErrorMessage ?? 'Не удалось отправить письмо',
      );
    }
  }

  Future<void> _submit(
    BuildContext context,
    AuthCubit cubit,
    AuthState state,
  ) async {
    if (Platform.isIOS) HapticFeedback.selectionClick();
    final isLogin = state.status == AuthStatus.login;
    if (isLogin) {
      final success = await cubit.signIn();
      if (!success) {
        if (!context.mounted) return;
        await MessageDialog.show(
          context: context,
          titleText: 'Не получилось войти',
          leadingIcon: Icons.error_outline_rounded,
          leadingIconColor: AppColor.danger,
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
          titleText: 'Не получилось создать аккаунт',
          leadingIcon: Icons.error_outline_rounded,
          leadingIconColor: AppColor.danger,
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
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformTapScale(
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.accent,
            disabledBackgroundColor: AppColor.accent.withValues(alpha: 0.78),
            foregroundColor: AppColor.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.brPill),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
                child: child,
              ),
            ),
            child: loading
                ? const WarmLoader(
                    key: ValueKey('loader'),
                    size: 22,
                    color: AppColor.white,
                  )
                : Text(
                    label,
                    key: const ValueKey('label'),
                    style: AppTextStyle.button(AppColor.white),
                  ),
          ),
        ),
      ),
    );
  }
}
