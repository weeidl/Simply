import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class AppBarWidget extends StatelessWidget {
  final String nameScreen;
  final bool isLight;
  final bool showBackButton;
  final bool showIconPeople;

  const AppBarWidget({
    super.key,
    required this.nameScreen,
    this.isLight = true,
    this.showBackButton = false,
    this.showIconPeople = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton)
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColor.white,
                weight: 24,
              ),
            ),
          if (showBackButton) const SizedBox(width: 8),
          Text(
            nameScreen,
            style: AppTextStyle.title2(
              isLight ? AppColor.greyDark : AppColor.white,
            ),
          ),
          if (showIconPeople) ...[
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
        ],
      ),
    );
  }
}
