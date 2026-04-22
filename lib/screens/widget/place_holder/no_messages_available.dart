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
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/message.svg',
            width: 64,
            height: 64,
            colorFilter: const ColorFilter.mode(
              AppColor.greyDarkInverted,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No messages available',
            style: AppTextStyle.paragraph(AppColor.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
