import 'package:flutter/material.dart';
import 'package:simply/screens/widget/rounded_button.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

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
    final body = textStyle ?? AppTextStyle.bodyM(AppColor.inkSecondary);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.divider,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (titleTextWidget != null) titleTextWidget!,
          if (text != null)
            Text(text!, style: body, textAlign: TextAlign.center),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description!, style: body, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          RoundedButton(
            width: double.infinity,
            buttonColor: buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderRadius: borderRadiusButton ?? AppRadii.brPill,
            onPressed: onTapButton ?? () => Navigator.maybePop(context),
            child: Text(buttonText, style: buttonTextStyle),
          ),
          if (buttonTwoWidget != null) buttonTwoWidget!,
          if (buttonThreeWidget != null) buttonThreeWidget!,
        ],
      ),
    );
  }
}
