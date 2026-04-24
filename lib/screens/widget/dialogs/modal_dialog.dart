import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/screens/widget/rounded_button.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

/// Warm bottom-sheet scaffold used by [ConfirmationDialog] and [MessageDialog].
///
/// The public field shape (titleTextWidget / text / buttonText / buttonTwoWidget
/// / buttonThreeWidget) is kept stable so existing call sites keep compiling.
/// The entrance animation is layered on top of the native bottom-sheet slide:
/// iOS gets a short spring (easeOutBack) on the content block, Android gets a
/// lighter fade + slight upward drift — matches the platform feel while staying
/// inside the Simply warm palette.
class ModalDialog extends StatefulWidget {
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
  State<ModalDialog> createState() => _ModalDialogState();
}

class _ModalDialogState extends State<ModalDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  bool get _isIOS => Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isIOS ? 460 : 280),
    );
    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: _isIOS ? Curves.easeOutBack : Curves.easeOutCubic,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);
    _scale = Tween<double>(
      begin: _isIOS ? 0.96 : 0.98,
      end: 1.0,
    ).animate(curve);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _primary() {
    if (_isIOS) HapticFeedback.selectionClick();
    (widget.onTapButton ?? () => Navigator.maybePop(context))();
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.textStyle ?? AppTextStyle.bodyM(AppColor.inkSecondary);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: SlideTransition(
            position: _slide,
            child: ScaleTransition(
              scale: _scale,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 14,
          bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (widget.titleTextWidget != null) widget.titleTextWidget!,
            if (widget.text != null)
              Text(widget.text!, style: body, textAlign: TextAlign.center),
            if (widget.description != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.description!,
                style: body,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 26),
            PlatformTapScale(
              child: RoundedButton(
                width: double.infinity,
                buttonColor: widget.buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                borderRadius: widget.borderRadiusButton ?? AppRadii.brPill,
                onPressed: _primary,
                child: Text(widget.buttonText, style: widget.buttonTextStyle),
              ),
            ),
            if (widget.buttonTwoWidget != null) widget.buttonTwoWidget!,
            if (widget.buttonThreeWidget != null) widget.buttonThreeWidget!,
          ],
        ),
      ),
    );
  }
}
