import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

/// Detail-screen app bar: circular back button on the left, centered title
/// and optional trailing slot. Lives on the warm background.
class AppBarWidget extends StatelessWidget {
  final String? title;
  final Widget? subtitle;
  final bool showBackButton;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onBack;

  const AppBarWidget({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.leading,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          if (showBackButton)
            _CircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          if (showBackButton) const SizedBox(width: 10),
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTextStyle.title(AppColor.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (subtitle != null) subtitle!,
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.brPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brPill,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.surface,
            shape: BoxShape.circle,
            boxShadow: AppShadows.s,
            border: Border.all(color: const Color(0x0A281910)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColor.ink),
        ),
      ),
    );
  }
}
