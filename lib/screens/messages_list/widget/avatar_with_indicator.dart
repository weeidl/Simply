import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class AvatarWithIndicator extends StatelessWidget {
  final int? notificationCount;

  const AvatarWithIndicator({
    super.key,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final countNull = notificationCount == null;
    return Container(
      height: 54,
      width: 54,
      margin: const EdgeInsets.all(4),
      child: countNull
          ? const CircleAvatar(
              backgroundColor: AppColor.greyLight,
              radius: 24,
              child: Icon(
                Icons.perm_identity,
                color: AppColor.greyDark,
              ),
            )
          : Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.orange,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    notificationCount.toString(),
                    style: AppTextStyle.title5(
                      AppColor.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
    );
  }
}
