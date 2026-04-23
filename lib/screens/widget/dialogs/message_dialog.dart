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
  }) {
    return showModalBottomSheet(
      elevation: 0,
      context: context,
      useSafeArea: useSafeArea,
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
        child: Padding(
          padding: EdgeInsets.only(
            bottom:
                useSafeArea ? MediaQuery.of(context).viewPadding.bottom : 0,
          ),
          child: ModalDialog(
            text: text,
            titleTextWidget: titleText != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titleText,
                        style: AppTextStyle.title(AppColor.ink),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                : null,
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
}
