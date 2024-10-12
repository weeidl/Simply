import 'package:flutter/material.dart';
import 'package:sms_forward_app/screens/messages_list/widget/avatar_with_indicator.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class MessagesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String message;
  final String time;
  final int? notificationCount;

  const MessagesWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.message,
    required this.time,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarWithIndicator(
          imagePath: imagePath,
          notificationCount: notificationCount,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyle.title5(AppColor.greyDark),
                  ),
                  const Spacer(),
                  Text(time),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.captionSM(AppColor.greyDark),
                // softWrap: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
