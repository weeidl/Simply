import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

class BuildSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BuildSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.bgAlt,
        borderRadius: AppRadii.brR2,
        border: Border.all(color: AppColor.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.titleSm(AppColor.ink)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyle.bodySm(AppColor.inkTertiary)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColor.white,
              activeTrackColor: AppColor.accent,
              inactiveThumbColor: AppColor.white,
              inactiveTrackColor: AppColor.inkPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}
