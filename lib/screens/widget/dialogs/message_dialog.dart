// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_forward_app/screens/widget/dialogs/modal_dialog.dart';

// Package imports:

// Project imports:
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

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
      backgroundColor: AppColor.greyDark2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColor.greyDark2,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: useSafeArea ? MediaQuery.of(context).viewPadding.bottom : 0,
          ),
          child: ModalDialog(
            text: text,
            titleTextWidget: titleText != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: AppTextStyle.title2(
                          AppColor.greyDarkInverted,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  )
                : null,
            description: description,
            buttonTextStyle:
                buttonTextStyle ?? AppTextStyle.paragraphM(AppColor.magenta),
            buttonText: buttonText ?? 'close',
            buttonColor: buttonColor ?? AppColor.magentaLight,
            onTapButton: onTapButton,
            borderRadiusButton: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
