import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/bacgraund_widget.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => const PrivacyPolicyScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: const AppBarWidget(
        nameScreen: 'Privacy Policy',
        isLight: false,
        showBackButton: true,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(24),
            Center(
              child: Text(
                'Coming Soon',
                style: AppTextStyle.title2(AppColor.greyDark),
              ),
            ),
            const Gap(16),
            Text(
              'We are currently working on our Privacy Policy. Please check back later for updates.',
              style: AppTextStyle.paragraph(AppColor.greyDark),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.greyDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What to expect:',
                    style: AppTextStyle.titleAccent3(AppColor.greyDark),
                  ),
                  const Gap(8),
                  Text(
                    '• Information about data collection\n'
                    '• How we use your data\n'
                    '• Your privacy rights\n'
                    '• Data security measures\n'
                    '• Contact information',
                    style: AppTextStyle.paragraph(AppColor.greyDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
