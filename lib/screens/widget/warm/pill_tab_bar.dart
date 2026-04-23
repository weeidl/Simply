import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class PillTab {
  final IconData icon;
  final String label;

  const PillTab({required this.icon, required this.label});
}

/// Floating pill bottom navigation. Active tab fills with accent and reveals
/// its label; inactive tabs collapse to icon-only.
class PillTabBar extends StatelessWidget {
  final List<PillTab> tabs;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const PillTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: AppRadii.brPill,
          boxShadow: AppShadows.m,
          border: Border.all(color: const Color(0x0A281910)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final on = i == activeIndex;
            return Material(
              color: Colors.transparent,
              borderRadius: AppRadii.brPill,
              child: InkWell(
                borderRadius: AppRadii.brPill,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: on ? AppColor.accent : Colors.transparent,
                    borderRadius: AppRadii.brPill,
                    boxShadow: on ? AppShadows.accent : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 20,
                        color: on ? AppColor.white : AppColor.inkTertiary,
                      ),
                      if (on) ...[
                        const SizedBox(width: 8),
                        Text(
                          tab.label,
                          style: AppTextStyle.bodySmBold(AppColor.white),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
