import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';

/// Rounded square icon background used in settings rows and similar lists.
/// Defaults to accentSoft + accentDeep so callers can pair custom colors when
/// they want to brand a section.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color? background;
  final Color? foreground;
  final double size;

  const IconTile({
    super.key,
    required this.icon,
    this.background,
    this.foreground,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? AppColor.accentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: size * 0.54,
        color: foreground ?? AppColor.accentDeep,
      ),
    );
  }
}
