import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColor.divider, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: AppTextStyle.caption(AppColor.inkTertiary),
            ),
          ),
          const Expanded(child: Divider(color: AppColor.divider, thickness: 1)),
        ],
      ),
    );
  }
}
