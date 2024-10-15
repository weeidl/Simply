import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simply/screens/widget/dialogs/modal_dialog.dart';
import 'package:simply/screens/widget/rounded_button.dart';
import 'package:simply/themes/colors.dart';
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
      backgroundColor: AppColor.greyLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      builder: (_) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColor.greyLight,
        ),
        child: ModalDialog(
          text: subText,
          textStyle: subTextStyle,
          buttonTextStyle:
              buttonTextStyleOne ?? AppTextStyle.paragraphB(AppColor.white),
          titleTextWidget: text != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null) ...[
                        Text(
                          title.toUpperCase(),
                          style: AppTextStyle.captionSC(
                            AppColor.greyDark.withOpacity(0.44),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        text,
                        style: AppTextStyle.title2(
                          AppColor.greyDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                )
              : null,
          onTapButton: onTapButtonOne,
          buttonTwoWidget: buttonTextTwo != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    RoundedButton(
                      width: double.infinity,
                      buttonColor: buttonTwoColor ?? AppColor.magentaLight,
                      padding: const EdgeInsets.all(12),
                      borderRadius:
                          borderRadiusButton ?? BorderRadius.circular(12),
                      onPressed: onTapButtonTwo,
                      child: Text(
                        buttonTextTwo,
                        style: buttonTextStyleTwo ??
                            AppTextStyle.paragraphB(AppColor.magenta),
                      ),
                    ),
                  ],
                )
              : null,
          buttonThreeWidget: buttonTextThree != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    RoundedButton(
                      width: double.infinity,
                      buttonColor: buttonThreeColor ?? AppColor.magentaLight,
                      padding: const EdgeInsets.all(12),
                      borderRadius:
                          borderRadiusButton ?? BorderRadius.circular(12),
                      onPressed: onTapButtonThree,
                      child: Text(
                        buttonTextThree,
                        style: buttonTextStyleThree ??
                            AppTextStyle.paragraphB(AppColor.magenta),
                      ),
                    ),
                  ],
                )
              : null,
          buttonText: buttonTextOne ?? 'cancel',
          buttonColor: AppColor.green,
          borderRadiusButton: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
