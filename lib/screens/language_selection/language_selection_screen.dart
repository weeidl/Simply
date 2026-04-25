import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/bloc/locale/locale_cubit.dart';
import 'package:simply/l10n/app_localizations.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static Route route() {
    return platformPageRoute(
      builder: (context) => const LanguageSelectionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.language,
        showBackButton: true,
      ),
      child: BlocBuilder<LocaleCubit, dynamic>(
        builder: (context, state) {
          final cubit = context.read<LocaleCubit>();
          final l10n = AppLocalizations.of(context)!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Text(
                'Choose your preferred language',
                style: AppTextStyle.bodySm(AppColor.inkTertiary),
              ),
              const SizedBox(height: 20),
              _LanguageCard(
                name: l10n.languageEn,
                languageCode: 'en',
                isSelected: cubit.isEnglish(),
                flag: '🇬🇧',
                onTap: () async {
                  await cubit.setLocale('en');
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 12),
              _LanguageCard(
                name: l10n.languageRu,
                languageCode: 'ru',
                isSelected: cubit.isRussian(),
                flag: '🇷🇺',
                onTap: () async {
                  await cubit.setLocale('ru');
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 24),
              _LanguageInfo(l10n: l10n),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String name;
  final String languageCode;
  final bool isSelected;
  final String flag;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.name,
    required this.languageCode,
    required this.isSelected,
    required this.flag,
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brR3,
            boxShadow: AppShadows.s,
            border: Border.all(
              color: isSelected ? AppColor.accent : const Color(0x0A281910),
              width: isSelected ? 1.5 : 1,
            ),
            color: isSelected ? AppColor.accentSoft : AppColor.surface,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColor.bgAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(flag, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyle.titleSm(AppColor.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      languageCode.toUpperCase(),
                      style: AppTextStyle.caption(AppColor.inkTertiary),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColor.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColor.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageInfo extends StatelessWidget {
  final AppLocalizations l10n;

  const _LanguageInfo({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.accentSoft,
        borderRadius: AppRadii.brR3,
        border: Border.all(color: AppColor.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language will be changed immediately',
            style: AppTextStyle.titleSm(AppColor.accent),
          ),
          const SizedBox(height: 8),
          Text(
            'All text in the app will be displayed in your selected language.',
            style: AppTextStyle.bodySm(AppColor.accentDeep),
          ),
        ],
      ),
    );
  }
}
