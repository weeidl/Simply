import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class BuildSwitchTile extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BuildSwitchTile({
    super.key,
    required this.context,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.title5(AppColor.greyDark2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyle.captionSM(AppColor.grey2),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColor.white,
              activeTrackColor: AppColor.green,
              inactiveThumbColor: AppColor.grey2,
              inactiveTrackColor: AppColor.greyLight,
            ),
          ),
        ],
      ),
    );
  }
}
