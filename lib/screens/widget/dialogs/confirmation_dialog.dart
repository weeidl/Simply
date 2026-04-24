import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simply/screens/widget/dialogs/modal_dialog.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/screens/widget/rounded_button.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

class ConfirmationDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    String? subText,
    TextStyle? subTextStyle,
    String? buttonTextOne,
    String? buttonTextTwo,
    String? buttonTextThree,
    TextStyle? buttonTextStyleOne,
    TextStyle? buttonTextStyleTwo,
    TextStyle? buttonTextStyleThree,
    Color? buttonTwoColor,
    Color? buttonThreeColor,
    String? text,
    VoidCallback? onTapButtonOne,
    VoidCallback? onTapButtonTwo,
    VoidCallback? onTapButtonThree,
    BorderRadiusGeometry? borderRadiusButton,
    String? title,
    IconData? leadingIcon,
    Color? leadingIconColor,
  }) {
    return showModalBottomSheet<T>(
      elevation: 0,
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      barrierColor: AppColor.black.withValues(alpha: 0.32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: Duration(milliseconds: Platform.isIOS ? 440 : 300),
        reverseDuration: const Duration(milliseconds: 220),
      ),
      builder: (_) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColor.surface,
        ),
        child: ModalDialog(
          text: subText,
          textStyle: subTextStyle,
          buttonTextStyle:
              buttonTextStyleOne ?? AppTextStyle.button(AppColor.white),
          titleTextWidget: _buildTitleBlock(
            title: title,
            text: text,
            leadingIcon: leadingIcon,
            leadingIconColor: leadingIconColor,
          ),
          onTapButton: onTapButtonOne,
          buttonTwoWidget: buttonTextTwo != null
              ? _SecondaryAction(
                  text: buttonTextTwo,
                  color: buttonTwoColor ?? AppColor.bgAlt,
                  textStyle: buttonTextStyleTwo ??
                      AppTextStyle.button(AppColor.accentDeep),
                  borderRadius: borderRadiusButton ?? AppRadii.brPill,
                  onTap: onTapButtonTwo,
                )
              : null,
          buttonThreeWidget: buttonTextThree != null
              ? _SecondaryAction(
                  text: buttonTextThree,
                  color: buttonThreeColor ?? AppColor.bgAlt,
                  textStyle: buttonTextStyleThree ??
                      AppTextStyle.button(AppColor.inkSecondary),
                  borderRadius: borderRadiusButton ?? AppRadii.brPill,
                  onTap: onTapButtonThree,
                )
              : null,
          buttonText: buttonTextOne ?? 'OK',
          buttonColor: AppColor.accent,
          borderRadiusButton: AppRadii.brPill,
        ),
      ),
    );
  }

  static Widget? _buildTitleBlock({
    String? title,
    String? text,
    IconData? leadingIcon,
    Color? leadingIconColor,
  }) {
    if (text == null && title == null && leadingIcon == null) return null;
    final iconColor = leadingIconColor ?? AppColor.accentDeep;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(leadingIcon, size: 26, color: iconColor),
          ),
          const SizedBox(height: 14),
        ],
        if (title != null) ...[
          Text(
            title.toUpperCase(),
            style: AppTextStyle.captionUpper(AppColor.inkTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
        if (text != null) ...[
          Text(
            text,
            style: AppTextStyle.title(AppColor.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color color;
  final BorderRadiusGeometry borderRadius;
  final VoidCallback? onTap;

  const _SecondaryAction({
    required this.text,
    required this.textStyle,
    required this.color,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: PlatformTapScale(
        child: RoundedButton(
          width: double.infinity,
          buttonColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          borderRadius: borderRadius,
          onPressed: onTap == null
              ? null
              : () {
                  if (Platform.isIOS) HapticFeedback.selectionClick();
                  onTap!();
                },
          child: Text(text, style: textStyle),
        ),
      ),
    );
  }
}
