import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

/// Pill chip used as a filter tag. Active state fills with brand accent and
/// projects a soft glow. Optional [count] renders the inset counter pill.
class WarmChip extends StatelessWidget {
  final String label;
  final bool active;
  final int? count;
  final VoidCallback? onTap;

  const WarmChip({
    super.key,
    required this.label,
    this.active = false,
    this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColor.white : AppColor.inkSecondary;
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.brPill,
      child: InkWell(
        borderRadius: AppRadii.brPill,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColor.accent : AppColor.surface,
            borderRadius: AppRadii.brPill,
            border: Border.all(
              color: active ? Colors.transparent : const Color(0x0F281910),
            ),
            boxShadow: active ? AppShadows.accent : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyle.bodySmBold(fg)),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.25)
                        : AppColor.accentSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? AppColor.white : AppColor.accentDeep,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
