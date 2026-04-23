import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

/// Canonical app search control: one continuous pill with built-in leading
/// search icon and optional trailing action.
class WarmSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final VoidCallback? onFilterTap;

  const WarmSearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.onTap,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.trailingIcon,
    this.onTrailingTap,
    this.onFilterTap,
  });

  @override
  State<WarmSearchField> createState() => _WarmSearchFieldState();
}

class _WarmSearchFieldState extends State<WarmSearchField> {
  FocusNode? _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  bool get _isFocused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode == null ? FocusNode() : null;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant WarmSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) return;

    if (oldWidget.focusNode != null) {
      oldWidget.focusNode!.removeListener(_handleFocusChange);
    } else {
      _internalFocusNode?.removeListener(_handleFocusChange);
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    }

    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final trailingIcon = widget.trailingIcon ??
        ((widget.onTrailingTap ?? widget.onFilterTap) != null
            ? Icons.tune_rounded
            : null);
    final trailingTap = widget.onTrailingTap ?? widget.onFilterTap;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: AppRadii.brPill,
        boxShadow: _isFocused ? AppShadows.m : AppShadows.s,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        cursorColor: AppColor.accentDeep,
        style: AppTextStyle.bodyM(AppColor.ink),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColor.surface,
          hintText: widget.hint,
          hintStyle: AppTextStyle.bodyM(AppColor.inkPlaceholder),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: const Padding(
            padding: EdgeInsetsDirectional.only(start: 16, end: 8),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColor.inkTertiary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: trailingIcon == null
              ? null
              : _SearchTrailingAction(
                  icon: trailingIcon,
                  onTap: trailingTap,
                ),
          suffixIconConstraints: const BoxConstraints(minWidth: 52),
          border: const OutlineInputBorder(
            borderRadius: AppRadii.brPill,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.brPill,
            borderSide: BorderSide(
              color: Color(0x0A281910),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadii.brPill,
            borderSide: BorderSide(
              color: AppColor.accent.withValues(alpha: 0.32),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchTrailingAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SearchTrailingAction({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 18,
      color: AppColor.inkTertiary,
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: iconWidget,
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}
