import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sms_forward_app/themes/colors.dart';

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
      radius: 34,
      lineWidth: 8,
      animation: true,
      percent: progress / 100,
      center: Text(
        textProgress,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      backgroundColor: AppColor.greyDarkInverted,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: AppColor.orange,
    );
  }
}
