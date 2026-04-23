import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';

/// Soft white card with warm shadow and hairline border. The base surface
/// for everything in the new design.
class WarmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  final BorderSide? border;

  const WarmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadii.r4,
    this.color,
    this.shadow,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    final box = Container(
      decoration: BoxDecoration(
        color: color ?? AppColor.surface,
        borderRadius: br,
        boxShadow: shadow ?? AppShadows.s,
        border: Border.fromBorderSide(
          border ??
              const BorderSide(
                color: Color(0x0A281910),
                width: 1,
              ),
        ),
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      borderRadius: br,
      child: InkWell(
        borderRadius: br,
        onTap: onTap,
        child: box,
      ),
    );
  }
}
