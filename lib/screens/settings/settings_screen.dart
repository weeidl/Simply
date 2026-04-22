import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simply/screens/auth/screen/auth_screen.dart';
import 'package:simply/screens/settings/widget/setting_widget.dart';
import 'package:simply/screens/splash/cubit/splash_cubit.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/screens/widget/dialogs/confirmation_dialog.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';
import 'package:simply/screens/contact_us/screen/contact_us_screen.dart';
import 'package:simply/screens/privacy_policy/screen/privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _onLogoutTap(BuildContext context) async {
    await ConfirmationDialog.show(
      context: context,
      text: 'Log out of your account?',
      buttonTextOne: 'Log Out',
      onTapButtonOne: () async {
        final splashCubit = context.read<SplashCubit>();
        final navigator = Navigator.of(context);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_new_device', true);

        final signedOut = await splashCubit.signOut();
        if (!signedOut) return;

        navigator.pushAndRemoveUntil(
          AuthScreen.route(),
          (route) => false,
        );
      },
      buttonTextTwo: 'Cancel',
      buttonTextStyleTwo: AppTextStyle.paragraphB(AppColor.green),
      buttonTwoColor: AppColor.green.withValues(alpha: 0.2),
      onTapButtonTwo: () => Navigator.pop(context),
    );
  }

  String _displayName(User? user) {
    if (user == null) return 'User';
    final name = user.displayName;
    if (name != null && name.trim().isNotEmpty) return name;
    return user.email ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return BackgroundWidget(
      appBar: const AppBarWidget(
        nameScreen: 'Settings',
        isLight: false,
      ),
      childAppBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColor.white,
              radius: 32,
              child: SvgPicture.asset(
                'assets/icons/profile.svg',
                height: 28,
              ),
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName(user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.titleAccent3(AppColor.white),
                  ),
                  Text(
                    user?.email ?? 'Simply',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.paragraph(AppColor.white),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => _onLogoutTap(context),
              child: SvgPicture.asset(
                'assets/icons/logout.svg',
                height: 38,
                colorFilter: const ColorFilter.mode(
                  AppColor.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(24),
            const SettingWidget(
              title: 'Edit Profile',
              icon: 'assets/icons/edit_profile.svg',
              comingSoon: true,
            ),
            const SettingWidget(
              title: 'Language',
              icon: 'assets/icons/language.svg',
              comingSoon: true,
            ),
            const SettingWidget(
              title: 'Push Notification',
              icon: 'assets/icons/notification.svg',
              comingSoon: true,
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                PrivacyPolicyScreen.route(),
              ),
              child: const SettingWidget(
                title: 'Privacy Policy',
                icon: 'assets/icons/privacy_policy.svg',
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                ContactUsScreen.route(),
              ),
              child: const SettingWidget(
                title: 'Contact Us',
                icon: 'assets/icons/call.svg',
              ),
            ),
            const Gap(24),
            Text(
              'Created by © Weeidl',
              style: AppTextStyle.captionS(AppColor.grey),
            ),
          ],
        ),
      ),
    );
  }
}
