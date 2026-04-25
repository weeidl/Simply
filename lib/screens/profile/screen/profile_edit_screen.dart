import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/l10n/app_localizations.dart';
import 'package:simply/screens/profile/cubit/profile_cubit.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/screens/widget/warm/warm_loader.dart';
import 'package:simply/screens/widget/warm/warm_toast.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  static Route route({required ProfileCubit cubit}) {
    return platformPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const ProfileEditScreen(),
      ),
    );
  }

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _nameController;
  final FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileCubit>().state;
    _nameController = TextEditingController(text: state.displayName);
    _nameController.addListener(_onNameChanged);
    _nameFocus.addListener(() => setState(() {}));
  }

  void _onNameChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    FocusManager.instance.primaryFocus?.unfocus();
    if (Platform.isIOS) HapticFeedback.selectionClick();
    final cubit = context.read<ProfileCubit>();
    final ok = await cubit.updateDisplayName(_nameController.text);
    if (!mounted) return;
    if (ok) {
      WarmToast.success(
        context,
        l10n.saveProfile,
        icon: Icons.check_rounded,
      );
      Navigator.of(context).maybePop();
    } else {
      final message = switch (cubit.state.errorCode) {
        ProfileErrorCode.nameEmpty => l10n.profileNameEmptyError,
        ProfileErrorCode.sessionExpired => l10n.profileSessionExpiredError,
        ProfileErrorCode.saveFailed => l10n.saveError,
        null => l10n.saveError,
      };
      WarmToast.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return BackgroundWidget(
          appBar: AppBarWidget(
            title: l10n.profileEditing,
            showBackButton: true,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                _AvatarPreview(
                  name: _currentPreviewName(state),
                  comingSoon: l10n.coming,
                ),
                const SizedBox(height: 24),
                _SectionLabel(l10n.personalData),
                const SizedBox(height: 8),
                _FormCard(
                  children: [
                    _LabeledField(
                      label: l10n.name,
                      child: _NameField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        hint: l10n.yourName,
                      ),
                    ),
                    const _FieldDivider(),
                    _LabeledField(
                      label: l10n.email,
                      trailing: _LockedBadge(label: l10n.protected),
                      child: Text(
                        state.email.isEmpty ? '—' : state.email,
                        style: AppTextStyle.bodyM(AppColor.inkTertiary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.changeEmailInfo,
                    style: AppTextStyle.caption(AppColor.inkTertiary),
                  ),
                ),
                const SizedBox(height: 28),
                _SaveButton(
                  label: l10n.save,
                  loading: state.isSaving,
                  enabled: _nameController.text.trim().isNotEmpty,
                  onTap: _save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _currentPreviewName(ProfileState state) {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) return name;
    if (state.email.isNotEmpty) return state.email.split('@').first;
    return '?';
  }
}

class _AvatarPreview extends StatelessWidget {
  final String name;
  final String comingSoon;

  const _AvatarPreview({required this.name, required this.comingSoon});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+|@'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
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
              style: AppTextStyle.display(AppColor.white).copyWith(fontSize: 34),
            ),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppShadows.s,
                border: Border.all(color: AppColor.divider),
              ),
              child: Text(
                comingSoon,
                style: AppTextStyle.micro(AppColor.accentDeep),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTextStyle.captionUpper(AppColor.inkTertiary)
            .copyWith(letterSpacing: 1),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

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

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: AppColor.divider, height: 1, thickness: 1),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;

  const _LabeledField({
    required this.label,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyle.caption(AppColor.inkTertiary),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;

  const _NameField({
    required this.controller,
    required this.focusNode,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      style: AppTextStyle.titleSm(AppColor.ink),
      cursorColor: AppColor.accentDeep,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        hintText: hint,
      ),
    );
  }
}

class _LockedBadge extends StatelessWidget {
  final String label;
  const _LockedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.bgAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 12,
            color: AppColor.inkTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyle.micro(AppColor.inkTertiary),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _SaveButton({
    required this.label,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !loading;
    return PlatformTapScale(
      child: Material(
        color: isActive
            ? AppColor.accent
            : AppColor.accent.withValues(alpha: 0.5),
        borderRadius: AppRadii.brPill,
        child: InkWell(
          borderRadius: AppRadii.brPill,
          onTap: isActive ? onTap : null,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadii.brPill,
              boxShadow: isActive ? AppShadows.accent : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: loading
                  ? const WarmLoader(
                      key: ValueKey('loader'),
                      size: 22,
                      color: AppColor.white,
                    )
                  : Text(
                      label,
                      key: const ValueKey('label'),
                      style: AppTextStyle.button(AppColor.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
