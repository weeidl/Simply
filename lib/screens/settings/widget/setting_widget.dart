import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class SettingWidget extends StatelessWidget {
  final String title;
  final String icon;
  const SettingWidget({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        height: 68,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColor.greyLight,
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: const ColorFilter.mode(
                AppColor.greyDark2,
                BlendMode.srcIn,
              ),
            ),
            const Gap(12),
            Text(
              title,
              style: AppTextStyle.paragraphM(AppColor.greyDark2),
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/icons/arrow_right.svg',
              colorFilter: ColorFilter.mode(
                AppColor.greyDark2.withOpacity(0.5),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
