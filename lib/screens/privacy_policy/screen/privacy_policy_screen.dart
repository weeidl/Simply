import 'package:flutter/material.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
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
        title: 'Политика конфиденциальности',
        showBackButton: true,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: AppColor.accentSoft,
              borderRadius: AppRadii.brR3,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: AppColor.accentDeep,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Готовим документ. Пока это заглушка — не используйте '
                    'приложение в публичных каналах.',
                    style: AppTextStyle.bodySm(AppColor.accentInk),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Что будет в политике', style: AppTextStyle.title(AppColor.ink)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: AppRadii.brR3,
              boxShadow: AppShadows.s,
              border: Border.all(color: const Color(0x0A281910)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Bullet(text: 'Какие данные собираются'),
                _Bullet(text: 'Как они используются'),
                _Bullet(text: 'Ваши права и контроль'),
                _Bullet(text: 'Меры безопасности и шифрование'),
                _Bullet(text: 'Контакты для запросов'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 12),
            decoration: const BoxDecoration(
              color: AppColor.accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.bodyM(AppColor.inkSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
