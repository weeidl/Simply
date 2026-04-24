import 'package:flutter/material.dart';
import 'package:simply/screens/widget/warm/icon_tile.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

/// Single row inside a SettingsGroup. Renders an icon tile, title/subtitle,
/// and an optional trailing slot (chevron, badge, switch).
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconBg;
  final Color? iconFg;
  final bool comingSoon;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconBg,
    this.iconFg,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            IconTile(icon: icon, background: iconBg, foreground: iconFg),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyle.titleSm(AppColor.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (comingSoon) ...[
                        const SizedBox(width: 8),
                        const _SoonBadge(),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: AppTextStyle.bodySm(AppColor.inkTertiary)
                          .copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColor.inkPlaceholder, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('Скоро', style: AppTextStyle.micro(AppColor.accentDeep)),
    );
  }
}
