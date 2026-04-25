import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:simply/l10n/app_localizations.dart';
import 'package:simply/screens/profile/cubit/profile_cubit.dart';
import 'package:simply/screens/profile/screen/profile_edit_screen.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/screens/widget/rounded_button.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static Route route() {
    return platformPageRoute(
      builder: (context) => BlocProvider(
        create: (_) => ProfileCubit(),
        child: const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackgroundWidget(
      appBar: AppBarWidget(
        title: l10n.profile,
        showBackButton: true,
      ),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _ProfileHero(
                name: _resolvedName(state, l10n),
                email: state.email,
              ),
              const SizedBox(height: 20),
              _InfoCard(state: state, l10n: l10n),
              const SizedBox(height: 24),
              _EditButton(
                onTap: () => _openEdit(context),
                l10n: l10n,
              ),
            ],
          );
        },
      ),
    );
  }

  String _resolvedName(ProfileState state, AppLocalizations l10n) {
    final n = state.displayName.trim();
    if (n.isNotEmpty) return n;
    if (state.email.isNotEmpty) return state.email.split('@').first;
    return l10n.user;
  }

  Future<void> _openEdit(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    await Navigator.of(context).push(
      ProfileEditScreen.route(cubit: cubit),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHero({required this.name, required this.email});

  String get _initials {
    final source = name.isNotEmpty ? name : (email.isNotEmpty ? email : '?');
    final parts = source.trim().split(RegExp(r'\s+|@'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.surface, AppColor.surfaceSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.brR4,
        boxShadow: AppShadows.s,
        border: Border.all(color: AppColor.accent.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.accent, AppColor.accentDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: AppShadows.accent,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style:
                  AppTextStyle.display(AppColor.white).copyWith(fontSize: 32),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyle.h1(AppColor.ink),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySm(AppColor.inkTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ProfileState state;
  final AppLocalizations l10n;

  const _InfoCard({required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat('d MMMM y', locale.languageCode);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: AppRadii.brR3,
        boxShadow: AppShadows.s,
        border: Border.all(color: const Color(0x0A281910)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: l10n.name,
            value: state.displayName.isEmpty ? '—' : state.displayName,
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.mail_outline_rounded,
            label: l10n.email,
            value: state.email.isEmpty ? '—' : state.email,
          ),
          if (state.memberSince != null) ...[
            const _RowDivider(),
            _InfoRow(
              icon: Icons.event_available_rounded,
              label: l10n.memberSince,
              value: dateFormat.format(state.memberSince!),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColor.accentDeep, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.caption(AppColor.inkTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSm(AppColor.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 70),
      child: Divider(color: AppColor.divider, height: 1, thickness: 1),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _EditButton({required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return PlatformTapScale(
      child: RoundedButton(
        width: double.infinity,
        buttonColor: AppColor.accent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: AppRadii.brPill,
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_outlined, size: 18, color: AppColor.white),
            const SizedBox(width: 8),
            Text(
              l10n.profileEditButton,
              style: AppTextStyle.button(AppColor.white),
            ),
          ],
        ),
      ),
    );
  }
}
