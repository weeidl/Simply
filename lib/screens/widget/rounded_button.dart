// Flutter imports:
import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class RoundedButton extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final String? text;
  final TextStyle? textStyle;
  final Color? buttonColor;
  final Color? disabledBackgroundColor;
  final VoidCallback? onPressed;
  final bool elevated;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final BorderSide? borderSide;
  final EdgeInsetsGeometry? paddingButton;

  const RoundedButton({
    super.key,
    this.width,
    this.height,
    this.child,
    this.text,
    this.disabledBackgroundColor,
    this.buttonColor,
    required this.onPressed,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.borderSide,
    this.paddingButton,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: width,
        height: height,
      ),
      child: InkWell(
        onTap: onPressed != null ? () {} : null,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            padding: WidgetStateProperty.all(paddingButton),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side:
                borderSide != null ? WidgetStateProperty.all(borderSide) : null,
            elevation: WidgetStateProperty.all(elevated ? 2 : 0),
            shape: WidgetStateProperty.all(
              borderRadius != null
                  ? RoundedRectangleBorder(borderRadius: borderRadius!)
                  : const StadiumBorder(),
            ),
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return disabledBackgroundColor ?? AppColor.orange;
                }
                return buttonColor ?? AppColor.violet;
              },
            ),
          ),
          child: Container(
            padding: padding,
            child: FittedBox(
              child: child ??
                  Text(
                    text!,
                    style: textStyle ?? AppTextStyle.title4(AppColor.white),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
