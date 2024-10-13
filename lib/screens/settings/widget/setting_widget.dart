import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';

class SettingWidget extends StatelessWidget {
  final String title;
  const SettingWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColor.greyLight,
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
