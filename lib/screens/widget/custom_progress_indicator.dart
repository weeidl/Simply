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
      percent: progress / 100,
      center: Text(
        textProgress,
        style: AppTextStyle.captionSM(AppColor.greyDark2),
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          title,
          style: AppTextStyle.captionSC4(AppColor.greyDark2),
        ),
      ),
      backgroundColor: AppColor.greyDarkInverted,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: AppColor.orange,
    );
  }
}
