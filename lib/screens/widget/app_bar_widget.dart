import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class AppBarWidget extends StatelessWidget {
  final String nameScreen;
  final bool isLight;

  const AppBarWidget({
    super.key,
    required this.nameScreen,
    this.isLight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameScreen,
            style: AppTextStyle.title2(
              isLight ? AppColor.greyDark : AppColor.white,
            ),
          ),
          const Spacer(),
          ClipOval(
            child: Container(
              color: AppColor.greyDark.withOpacity(0.2),
              height: 40,
              width: 40,
              child: Icon(
                Icons.people,
                color: isLight ? AppColor.greyDark : AppColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
