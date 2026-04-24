import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

SnackBar buildWarmSnackBar({
  required String message,
  IconData icon = Icons.check_rounded,
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColor.surfaceSoft,
    elevation: 8,
    margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
    duration: const Duration(seconds: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: AppColor.accent.withValues(alpha: 0.24)),
    ),
    content: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColor.accentSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColor.accentDeep),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: AppTextStyle.bodySmBold(AppColor.inkSecondary),
          ),
        ),
      ],
    ),
  );
}

void showWarmSnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_rounded,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    buildWarmSnackBar(message: message, icon: icon),
  );
}
