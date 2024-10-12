import 'package:flutter/material.dart';
import 'package:sms_forward_app/extensions.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class MessageDetailsWidget extends StatelessWidget {
  final MessageDetails message;

  const MessageDetailsWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            message.date.formatFullDateTime(),
            style: AppTextStyle.captionS(AppColor.grey),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 44),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.greyLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IntrinsicWidth(
              child: Text(
                message.text,
                style: AppTextStyle.paragraph(AppColor.greyDark),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
