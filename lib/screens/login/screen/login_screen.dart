import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sms_forward_app/screens/login/cubit/auth_cubit.dart';
import 'package:sms_forward_app/screens/login/widget/custom_segmented_control.dart';
import 'package:sms_forward_app/screens/login/widget/custom_text_field.dart';
import 'package:sms_forward_app/screens/widget/dialogs/message_dialog.dart';
import 'package:sms_forward_app/screens/widget/divider_with_text.dart';
import 'package:sms_forward_app/screens/widget/sign_in_button.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class LoginScreenTest extends StatelessWidget {
  const LoginScreenTest({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.orange,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthUnauthenticated) {
            final cubit = context.read<AuthCubit>();

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildWelcomeText(state),
                          _buildSubtitleText(state.status),
                          const Gap(28),
                        ],
                      ),
                    ),
                  ),
                  _buildForm(context, cubit, state),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildWelcomeText(AuthUnauthenticated state) {
    return Text(
      state.status == AuthStatus.login ? 'Welcome back!' : 'Welcome!',
      style: AppTextStyle.displayAccent(AppColor.white),
    );
  }

  Widget _buildSubtitleText(AuthStatus status) {
    return Text(
      status == AuthStatus.login
          ? 'First you need to log in to your profile'
          : 'To get started, create your account',
      style: AppTextStyle.paragraph(AppColor.white),
    );
  }

  Widget _buildForm(
      BuildContext context, AuthCubit cubit, AuthUnauthenticated state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Сегментированный контроллер (Login/Register)
          CustomSegmentedControl(
            groupValue: state.status,
            onValueChanged: (newValue) {
              cubit.setSegmentedControlState(newValue);
            },
            children: {
              AuthStatus.login: Text(
                'Login',
                style: AppTextStyle.paragraph(AppColor.greyDark),
              ),
              AuthStatus.register: Text(
                'Register',
                style: AppTextStyle.paragraph(AppColor.greyDark),
              ),
            },
          ),
          const Gap(24),

          // Поле для имени (только при регистрации)
          if (state.status == AuthStatus.register)
            CustomTextField(
              controller: state.nameController,
              labelText: 'Full Name',
              prefixIcon: Icons.person,
              // errorText: state.nameError,
            ),
          const Gap(8),

          CustomTextField(
            controller: state.emailController,
            labelText: 'E-Mail',
            prefixIcon: Icons.email,
            // errorText: state.emailError,
          ),
          const Gap(8),
          CustomTextField(
            controller: state.passwordController,
            labelText: 'Password',
            prefixIcon: Icons.lock,
            isPassword: true,
            // errorText: state.passwordError,
          ),
          const Gap(8),

          // Ссылка на восстановление пароля (только для логина)
          if (state.status == AuthStatus.login)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Forget password?',
                style: AppTextStyle.captionS(AppColor.orange),
              ),
            ),
          const Gap(20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.green,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () async {
              if (cubit.validateFields()) {
                if (state.status == AuthStatus.login) {
                  final i = await context.read<AuthCubit>().signIn();
                  if (i == false) {
                    await MessageDialog.show(
                      context: context,
                      text: 'message',
                      buttonText: 'Okey',
                    );
                  }
                } else {
                  // Логика для регистрации
                }
              }
            },
            child: Text(
              state.status == AuthStatus.login ? 'Login' : 'Register',
              style: AppTextStyle.paragraphM(AppColor.white),
            ),
          ),
          const Gap(24),
          const DividerWithText(text: 'Or login with'),
          const Gap(24),
          _buildSocialButtons(context),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SignInButton(
            text: 'Google',
            assetName: 'assets/icons/login_google.png',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SignInButton(
            text: 'Apple',
            assetName: 'assets/icons/login_apple.png',
            onPressed: () {},
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
