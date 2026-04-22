import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => const ContactUsScreen(),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: const AppBarWidget(
        nameScreen: 'Contact Us',
        isLight: false,
        showBackButton: true,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: AppTextStyle.title2(AppColor.greyDark2),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'d love to hear from you! Choose your preferred way to contact us.',
              style: AppTextStyle.captionSM(
                AppColor.greyDark2.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 32),
            _buildContactCard(
              context,
              'Email',
              'weeidlone@gmail.com',
              'assets/icons/email.svg',
              () => _launchUrl(context, 'mailto:weeidlone@gmail.com'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context,
              'Website',
              'weeidl.com',
              'assets/icons/website.svg',
              () => _launchUrl(context, 'https://weeidl.com'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context,
              'Social Media',
              'Follow us on social media',
              'assets/icons/social.svg',
              () => _launchUrl(context, 'https://www.instagram.com/weeidl'),
            ),
            const SizedBox(height: 32),
            Text(
              'Our Team',
              style: AppTextStyle.title2(AppColor.greyDark2),
            ),
            const SizedBox(height: 8),
            Text(
              'Meet the people behind Simply',
              style: AppTextStyle.captionSM(
                AppColor.greyDark2.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            _buildTeamMember(
              'Artur Rustamov',
              'Founder & CEO',
              'assets/icons/profile.svg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    String title,
    String subtitle,
    String iconPath,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColor.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.title5(AppColor.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyle.captionSM(
                      AppColor.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColor.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, String iconPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColor.white,
            radius: 24,
            child: SvgPicture.asset(
              iconPath,
              height: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyle.title5(AppColor.white),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: AppTextStyle.captionSM(
                    AppColor.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
