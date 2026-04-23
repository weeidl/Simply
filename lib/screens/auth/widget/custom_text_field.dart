import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final active = _focusNode.hasFocus;
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.isPassword && _obscureText,
      style: AppTextStyle.bodyM(AppColor.ink),
      decoration: InputDecoration(
        hintText: widget.labelText,
        hintStyle: AppTextStyle.bodyM(AppColor.inkPlaceholder),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 12),
          child: Icon(
            widget.prefixIcon,
            size: 20,
            color: active ? AppColor.accent : AppColor.inkTertiary,
          ),
        ),
        suffixIcon: widget.isPassword && active
            ? IconButton(
                padding: const EdgeInsets.only(right: 12),
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                  color: AppColor.inkTertiary,
                ),
                onPressed: () =>
                    setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }
}
