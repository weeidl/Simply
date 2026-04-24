import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simply/screens/widget/dialogs/modal_dialog.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

class MessageDialog {
  static Future<void> show({
    required BuildContext context,
    required String text,
    String? buttonText,
    String? titleText,
    TextStyle? buttonTextStyle,
    Color? buttonColor,
    String? description,
    Color? barrierColor,
    VoidCallback? onTapButton,
    bool useSafeArea = false,
    IconData? leadingIcon,
    Color? leadingIconColor,
  }) {
    return showModalBottomSheet(
      elevation: 0,
      context: context,
      useSafeArea: useSafeArea,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      barrierColor: barrierColor ?? AppColor.black.withValues(alpha: 0.32),
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
        child: Padding(
          padding: EdgeInsets.only(
            bottom: useSafeArea ? MediaQuery.of(context).viewPadding.bottom : 0,
          ),
          child: ModalDialog(
            text: text,
            titleTextWidget: _buildTitleBlock(
              titleText: titleText,
              leadingIcon: leadingIcon,
              leadingIconColor: leadingIconColor,
            ),
            description: description,
            buttonTextStyle:
                buttonTextStyle ?? AppTextStyle.button(AppColor.white),
            buttonText: buttonText ?? 'OK',
            buttonColor: buttonColor ?? AppColor.accent,
            onTapButton: onTapButton,
            borderRadiusButton: AppRadii.brPill,
          ),
        ),
      ),
    );
  }

  static Widget? _buildTitleBlock({
    String? titleText,
    IconData? leadingIcon,
    Color? leadingIconColor,
  }) {
    if (titleText == null && leadingIcon == null) return null;
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
        if (titleText != null) ...[
          Text(
            titleText,
            style: AppTextStyle.title(AppColor.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
