import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class CustomProgressIndicator extends StatelessWidget {
  final String textProgress;
  final String title;
  final int progress;

  const CustomProgressIndicator({
    super.key,
    required this.textProgress,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 30,
      lineWidth: 4,
      animation: true,
      percent: (progress.clamp(0, 100)) / 100,
      center: Text(
        textProgress,
        style: AppTextStyle.bodySmBold(AppColor.ink),
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          title,
          style: AppTextStyle.caption(AppColor.inkTertiary),
        ),
      ),
      backgroundColor: AppColor.bgAlt,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: AppColor.accent,
    );
  }
}
