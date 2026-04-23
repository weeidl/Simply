import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simply/screens/widget/dialogs/modal_dialog.dart';
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
  }) {
    return showModalBottomSheet(
      elevation: 0,
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
          titleTextWidget: text != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Text(
                        title.toUpperCase(),
                        style: AppTextStyle.captionUpper(AppColor.inkTertiary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      text,
                      style: AppTextStyle.title(AppColor.ink),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              : null,
          onTapButton: onTapButtonOne,
          buttonTwoWidget: buttonTextTwo != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    RoundedButton(
                      width: double.infinity,
                      buttonColor: buttonTwoColor ?? AppColor.bgAlt,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      borderRadius: borderRadiusButton ?? AppRadii.brPill,
                      onPressed: onTapButtonTwo,
                      child: Text(
                        buttonTextTwo,
                        style: buttonTextStyleTwo ??
                            AppTextStyle.button(AppColor.accentDeep),
                      ),
                    ),
                  ],
                )
              : null,
          buttonThreeWidget: buttonTextThree != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    RoundedButton(
                      width: double.infinity,
                      buttonColor: buttonThreeColor ?? AppColor.bgAlt,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      borderRadius: borderRadiusButton ?? AppRadii.brPill,
                      onPressed: onTapButtonThree,
                      child: Text(
                        buttonTextThree,
                        style: buttonTextStyleThree ??
                            AppTextStyle.button(AppColor.inkSecondary),
                      ),
                    ),
                  ],
                )
              : null,
          buttonText: buttonTextOne ?? 'OK',
          buttonColor: AppColor.accent,
          borderRadiusButton: AppRadii.brPill,
        ),
      ),
    );
  }
}
