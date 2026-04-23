import 'dart:ui';

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
        16,
        6,
        16,
        8 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadii.brPill,
          boxShadow: [
            ...AppShadows.glass,
            ...AppShadows.m,
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadii.brPill,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.glass,
                    AppColor.surface.withValues(alpha: 0.78),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadii.brPill,
                border: Border.all(color: AppColor.glassBorder),
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
                            horizontal: 16, vertical: 11),
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
                              size: 19,
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
          ),
        ),
      ),
    );
  }
}
