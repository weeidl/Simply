import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_forward_app/main.dart';
import 'package:sms_forward_app/screens/auth/screen/auth_screen.dart';
import 'package:sms_forward_app/screens/settings/widget/setting_widget.dart';
import 'package:sms_forward_app/screens/splash/cubit/splash_cubit.dart';
import 'package:sms_forward_app/screens/widget/app_bar_widget.dart';
import 'package:sms_forward_app/screens/widget/bacgraund_widget.dart';
import 'package:sms_forward_app/screens/widget/rounded_button.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: const AppBarWidget(
        nameScreen: 'Setting',
        isLight: false,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(24),
            const CircleAvatar(
              backgroundColor: AppColor.greyLight,
              radius: 44,
              child: Icon(
                Icons.person,
                color: AppColor.greyDark,
                size: 40,
              ),
            ),
            const Gap(8),
            Text(
              'User Name',
              style: AppTextStyle.titleAccent3(AppColor.greyDark),
            ),
            const Gap(24),
            const SettingWidget(title: 'Language'),
            const SettingWidget(title: 'Setting'),
            const SettingWidget(title: 'Privacy Policy'),
            const SettingWidget(title: 'Legal Information'),
            const SettingWidget(title: 'Contact Us'),
            const Gap(8),
            RoundedButton(
              height: 48,
              buttonColor: AppColor.greyLight,
              textStyle: AppTextStyle.paragraph(AppColor.orange),
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();

                final splashCubit = context.read<SplashCubit>();
                final navigator = Navigator.of(context);

                await prefs.setBool('is_new_device', false);

                final signOut = await splashCubit.signOut();
                if (signOut) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MyApp(),
                    ),
                    (route) => false,
                  );
                }
              },
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              text: 'Log Out',
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}
