import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/bloc/locale/locale_cubit.dart';
import 'package:simply/l10n/app_localizations.dart';
import 'package:simply/screens/auth/screen/auth_screen.dart';
import 'package:simply/screens/contact_us/screen/contact_us_screen.dart';
import 'package:simply/screens/language_selection/language_selection_screen.dart';
import 'package:simply/screens/privacy_policy/screen/privacy_policy_screen.dart';
import 'package:simply/screens/profile/screen/profile_screen.dart';
import 'package:simply/screens/settings/widget/setting_widget.dart';
import 'package:simply/screens/splash/cubit/splash_cubit.dart';
import 'package:simply/screens/widget/dialogs/confirmation_dialog.dart';
import 'package:simply/screens/widget/warm/warm_header.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;
    final localeCubit = context.read<LocaleCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WarmHeader(
          eyebrow: l10n.settingsHeaderEyebrow,
          title: l10n.settings,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              _ProfileCard(
                user: user,
                onTap: () => Navigator.of(context).push(ProfileScreen.route()),
                l10n: l10n,
              ),
              const SizedBox(height: 18),
              _PremiumBanner(l10n: l10n),
              const SizedBox(height: 18),
              _SectionTitle(l10n.account.toUpperCase()),
              _Group(children: [
                SettingsRow(
                  icon: Icons.person_outline_rounded,
                  title: l10n.profile,
                  subtitle: l10n.profileNameSubtitle,
                  onTap: () =>
                      Navigator.of(context).push(ProfileScreen.route()),
                ),
                const _Divider(),
                SettingsRow(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.notifications,
                  subtitle: l10n.notificationsSubtitle,
                  comingSoon: true,
                  onTap: () {},
                ),
                const _Divider(),
                SettingsRow(
                  icon: Icons.language_rounded,
                  title: l10n.language,
                  subtitle: localeCubit.isEnglish()
                      ? l10n.languageEn
                      : l10n.languageRu,
                  iconBg: const Color(0xFFE7F1FB),
                  iconFg: const Color(0xFF2F6BBA),
                  onTap: () => Navigator.of(context)
                      .push(LanguageSelectionScreen.route()),
                ),
              ]),
              const SizedBox(height: 16),
              _SectionTitle(l10n.help.toUpperCase()),
              _Group(children: [
                SettingsRow(
                  icon: Icons.shield_outlined,
                  title: l10n.privacyPolicy,
                  iconBg: const Color(0xFFE2F5EB),
                  iconFg: const Color(0xFF1A7F4B),
                  onTap: () =>
                      Navigator.push(context, PrivacyPolicyScreen.route()),
                ),
                const _Divider(),
                SettingsRow(
                  icon: Icons.support_agent_rounded,
                  title: l10n.contactUs,
                  iconBg: AppColor.accentSoft,
                  iconFg: AppColor.accentDeep,
                  onTap: () => Navigator.push(context, ContactUsScreen.route()),
                ),
              ]),
              const SizedBox(height: 24),
              _LogoutButton(
                onTap: () => _onLogoutTap(context),
                l10n: l10n,
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  l10n.madeWithLove,
                  style: AppTextStyle.caption(AppColor.inkTertiary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onLogoutTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await ConfirmationDialog.show(
      context: context,
      leadingIcon: Icons.logout_rounded,
      text: l10n.logoutConfirmation,
      buttonTextOne: l10n.logoutConfirmButton,
      onTapButtonOne: () async {
        final splashCubit = context.read<SplashCubit>();
        final navigator = Navigator.of(context);
        final signedOut = await splashCubit.signOut();
        if (!signedOut) return;
        navigator.pushAndRemoveUntil(AuthScreen.route(), (route) => false);
      },
      buttonTextTwo: l10n.cancel,
      buttonTextStyleTwo: AppTextStyle.button(AppColor.accent),
      buttonTwoColor: AppColor.accentSoft,
      onTapButtonTwo: () => Navigator.pop(context),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final User? user;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _ProfileCard({
    required this.user,
    required this.onTap,
    required this.l10n,
  });

  String get _name {
    final n = user?.displayName;
    if (n != null && n.trim().isNotEmpty) return n;
    return user?.email ?? l10n.user;
  }

  String get _initials {
    final source = (user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : (user?.email ?? '?'))
        .trim();
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+|@'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: AppRadii.brR4,
      child: InkWell(
        borderRadius: AppRadii.brR4,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brR4,
            boxShadow: AppShadows.s,
            border: Border.all(color: const Color(0x0A281910)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.accent, AppColor.accentDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child:
                    Text(_initials, style: AppTextStyle.title(AppColor.white)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.titleSm(AppColor.ink)),
                    const SizedBox(height: 2),
                    Text(user?.email ?? l10n.noEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodySm(AppColor.inkTertiary)),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColor.bgAlt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColor.inkSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  final AppLocalizations l10n;

  const _PremiumBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.accentDeep, AppColor.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.brR4,
        boxShadow: AppShadows.accent,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColor.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                size: 22, color: AppColor.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.simpplyPremium,
                    style: AppTextStyle.titleSm(AppColor.white)),
                const SizedBox(height: 2),
                Text(
                  l10n.premiumDescription,
                  style: AppTextStyle.bodySm(AppColor.white)
                      .copyWith(color: AppColor.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(l10n.open,
                style: AppTextStyle.button(AppColor.accentDeep)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyle.captionUpper(AppColor.inkTertiary)
            .copyWith(letterSpacing: 1.0),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: AppRadii.brR3,
        boxShadow: AppShadows.s,
        border: Border.all(color: const Color(0x0A281910)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 68),
      child: Divider(color: AppColor.divider, height: 1, thickness: 1),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _LogoutButton({required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.danger.withValues(alpha: 0.10),
      borderRadius: AppRadii.brR3,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brR3,
        child: SizedBox(
          height: 52,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded,
                    color: AppColor.danger, size: 18),
                const SizedBox(width: 8),
                Text(l10n.logout, style: AppTextStyle.button(AppColor.danger)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
