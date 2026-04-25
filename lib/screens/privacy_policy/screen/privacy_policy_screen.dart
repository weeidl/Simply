import 'package:flutter/material.dart';
import 'package:simply/l10n/app_localizations.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Route route() {
    return platformPageRoute(
      builder: (context) => const PrivacyPolicyScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackgroundWidget(
      appBar: AppBarWidget(
        title: l10n.privacyPolicy,
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
                    l10n.documentPlaceholder,
                    style: AppTextStyle.bodySm(AppColor.accentInk),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.privacyWhat, style: AppTextStyle.title(AppColor.ink)),
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
              children: [
                _Bullet(text: l10n.privacyDataCollected),
                _Bullet(text: l10n.privacyDataUsage),
                _Bullet(text: l10n.privacyYourRights),
                _Bullet(text: l10n.privacySecurity),
                _Bullet(text: l10n.privacyContact),
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
