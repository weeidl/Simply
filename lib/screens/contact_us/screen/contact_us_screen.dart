import 'package:flutter/material.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static Route route() {
    return platformPageRoute(
      builder: (context) => const ContactUsScreen(),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: const AppBarWidget(
        title: 'Связаться с нами',
        showBackButton: true,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'На связи',
            style: AppTextStyle.h1(AppColor.ink),
          ),
          const SizedBox(height: 6),
          Text(
            'Выберите удобный способ связи — мы ответим в рабочее время.',
            style: AppTextStyle.bodySm(AppColor.inkTertiary),
          ),
          const SizedBox(height: 20),
          _ContactCard(
            icon: Icons.mail_outline_rounded,
            title: 'Почта',
            subtitle: 'weeidlone@gmail.com',
            iconBg: AppColor.accentSoft,
            iconFg: AppColor.accentDeep,
            onTap: () => _launchUrl(context, 'mailto:weeidlone@gmail.com'),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.language_rounded,
            title: 'Сайт',
            subtitle: 'weeidl.com',
            iconBg: const Color(0xFFE7F1FB),
            iconFg: const Color(0xFF2F6BBA),
            onTap: () => _launchUrl(context, 'https://weeidl.com'),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.alternate_email_rounded,
            title: 'Соцсети',
            subtitle: 'instagram.com/weeidl',
            iconBg: const Color(0xFFF5E8FB),
            iconFg: const Color(0xFF8B3FB5),
            onTap: () =>
                _launchUrl(context, 'https://www.instagram.com/weeidl'),
          ),
          const SizedBox(height: 28),
          Text('Команда', style: AppTextStyle.title(AppColor.ink)),
          const SizedBox(height: 12),
          _TeamMember(
            name: 'Artur Rustamov',
            role: 'Founder & CEO',
            initials: 'AR',
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconFg;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: AppRadii.brR3,
      child: InkWell(
        borderRadius: AppRadii.brR3,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brR3,
            boxShadow: AppShadows.s,
            border: Border.all(color: const Color(0x0A281910)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadii.brR2,
                ),
                child: Icon(icon, color: iconFg, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.titleSm(AppColor.ink)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyle.bodySm(AppColor.inkTertiary),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColor.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  final String role;
  final String initials;

  const _TeamMember({
    required this.name,
    required this.role,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: AppRadii.brR3,
        boxShadow: AppShadows.s,
        border: Border.all(color: const Color(0x0A281910)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.accent, AppColor.accentDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyle.titleSm(AppColor.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyle.titleSm(AppColor.ink)),
                const SizedBox(height: 2),
                Text(role, style: AppTextStyle.bodySm(AppColor.inkTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
