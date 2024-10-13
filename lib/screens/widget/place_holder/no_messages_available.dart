import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class NoMessagesAvailable extends StatelessWidget {
  const NoMessagesAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/message.svg',
            colorFilter: const ColorFilter.mode(
              AppColor.greyDarkInverted,
              BlendMode.srcIn,
            ),
          ),
          Text(
            'No messages available',
            style: AppTextStyle.paragraph(AppColor.greyDarkInverted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
