import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class AvatarWithIndicator extends StatelessWidget {
  final String imagePath;
  final int? notificationCount;

  const AvatarWithIndicator({
    super.key,
    required this.imagePath,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SizedBox(
          height: 54,
          width: 54,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: CircleAvatar(
              backgroundColor: AppColor.greyLight,
              radius: 24.0,
              child: Icon(
                Icons.perm_identity,
                color: AppColor.greyDark,
              ),
            ),
          ),
        ),
        if (notificationCount != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: CircleAvatar(
              backgroundColor: AppColor.orange,
              radius: 12,
              child: Text(
                notificationCount.toString(),
                style: AppTextStyle.captionB(
                  AppColor.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
