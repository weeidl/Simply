import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sms_forward_app/screens/login/cubit/auth_segmented_control_cubit.dart';
import 'package:sms_forward_app/screens/login/widget/custom_segmented_control.dart';
import 'package:sms_forward_app/screens/login/widget/custom_text_field.dart';
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
      body: BlocBuilder<AuthSegmentedControlCubit, AuthSegmentedControlState>(
        builder: (context, state) {
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
                        _buildSubtitleText(state),
                        const Gap(28),
                      ],
                    ),
                  ),
                ),
                _buildForm(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeText(AuthSegmentedControlState state) {
    return Text(
      state == AuthSegmentedControlState.login ? 'Welcome back!' : 'Welcome!',
      style: AppTextStyle.displayAccent(AppColor.white),
    );
  }

  Widget _buildSubtitleText(AuthSegmentedControlState state) {
    return Text(
      state == AuthSegmentedControlState.login
          ? 'First you need to log in to your profile'
          : 'To get started, create your account',
      style: AppTextStyle.paragraph(AppColor.white),
    );
  }

  Widget _buildForm(BuildContext context, AuthSegmentedControlState state) {
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
          CustomSegmentedControl(
            groupValue: state,
            onValueChanged: (newValue) {
              context
                  .read<AuthSegmentedControlCubit>()
                  .setSegmentedControlState(newValue);
            },
            children: {
              AuthSegmentedControlState.login: Text(
                'Login',
                style: AppTextStyle.paragraph(AppColor.greyDark),
              ),
              AuthSegmentedControlState.register: Text(
                'Register',
                style: AppTextStyle.paragraph(AppColor.greyDark),
              ),
            },
          ),
          const Gap(24),
          if (state == AuthSegmentedControlState.register)
            const CustomTextField(
              labelText: 'Full Name',
              prefixIcon: Icons.person,
            ),
          const Gap(8),
          const CustomTextField(
            labelText: 'E-Mail',
            prefixIcon: Icons.email,
          ),
          const Gap(8),
          const CustomTextField(
            labelText: 'Password',
            prefixIcon: Icons.lock,
            isPassword: true,
          ),
          const Gap(8),
          if (state == AuthSegmentedControlState.login)
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
            onPressed: () {
              // Handle login or register action
            },
            child: Text(
              state == AuthSegmentedControlState.login ? 'Login' : 'Register',
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
