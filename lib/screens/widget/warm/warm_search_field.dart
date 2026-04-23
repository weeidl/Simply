import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

/// Pill-shaped search field with leading search icon and optional trailing
/// filter button. Stays light on the warm background.
class WarmSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onFilterTap;

  const WarmSearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: const Color(0x0F281910)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded,
              size: 20, color: AppColor.inkTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColor.accent,
              style: AppTextStyle.bodySm(AppColor.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle:
                    AppTextStyle.bodySm(AppColor.inkPlaceholder),
              ),
            ),
          ),
          if (onFilterTap != null)
            InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.tune_rounded,
                    size: 20, color: AppColor.inkTertiary),
              ),
            ),
        ],
      ),
    );
  }
}
