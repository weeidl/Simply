import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class AppBarBackWidget extends StatelessWidget {
  final String nameScreen;
  final bool isLight;

  const AppBarBackWidget({
    super.key,
    required this.nameScreen,
    this.isLight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColor.white,
              weight: 24,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            nameScreen,
            style: AppTextStyle.title2(
              isLight ? AppColor.greyDark : AppColor.white,
            ),
          ),
        ],
      ),
    );
  }
}
