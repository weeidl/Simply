import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class SettingWidget extends StatelessWidget {
  final String title;
  final String icon;
  final bool comingSoon;

  const SettingWidget({
    super.key,
    required this.title,
    required this.icon,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor =
        comingSoon ? AppColor.greyDark2.withValues(alpha: 0.4) : AppColor.greyDark2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        height: 68,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColor.greyLight,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn),
            ),
            const Gap(12),
            Text(title, style: AppTextStyle.paragraphM(mainColor)),
            if (comingSoon) ...[
              const Gap(8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColor.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soon',
                  style: AppTextStyle.captionS(AppColor.orange),
                ),
              ),
            ],
            const Spacer(),
            SvgPicture.asset(
              'assets/icons/arrow_right.svg',
              colorFilter: ColorFilter.mode(
                AppColor.greyDark2.withValues(alpha: 0.5),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
