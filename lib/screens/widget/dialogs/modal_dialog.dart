// Flutter imports:
import 'package:flutter/material.dart';
import 'package:sms_forward_app/screens/widget/rounded_button.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class ModalDialog extends StatelessWidget {
  final String? text;
  final TextStyle? textStyle;
  final String buttonText;
  final TextStyle buttonTextStyle;
  final Color buttonColor;
  final String? description;
  final VoidCallback? onTapButton;
  final Widget? buttonTwoWidget;
  final Widget? buttonThreeWidget;
  final Widget? titleTextWidget;
  final BorderRadiusGeometry? borderRadiusButton;

  const ModalDialog({
    super.key,
    this.text,
    this.description,
    required this.buttonText,
    required this.buttonTextStyle,
    required this.buttonColor,
    this.borderRadiusButton,
    this.titleTextWidget,
    this.buttonTwoWidget,
    this.buttonThreeWidget,
    this.onTapButton,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle =
        this.textStyle ?? AppTextStyle.paragraphM(AppColor.magentaLight);
    final imageScale =
        MediaQuery.textScalerOf(context).scale(textStyle.fontSize!) /
            textStyle.fontSize!;

    return Padding(
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 24,
        bottom: 44 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleTextWidget != null) titleTextWidget!,
          if (text != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: imageScale,
                  child: Image.asset(
                    "assets/flash.png",
                    width: 32,
                    color: AppColor.magenta,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text!,
                    style: textStyle,
                  ),
                ),
              ],
            ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: textStyle,
            ),
          ],
          const SizedBox(height: 24),
          RoundedButton(
            width: double.infinity,
            buttonColor: buttonColor,
            padding: const EdgeInsets.all(12),
            borderRadius: borderRadiusButton,
            onPressed: onTapButton ?? () => Navigator.maybePop(context),
            child: Text(
              buttonText,
              style: buttonTextStyle,
            ),
          ),
          if (buttonTwoWidget != null) buttonTwoWidget!,
          if (buttonThreeWidget != null) buttonThreeWidget!,
        ],
      ),
    );
  }
}
