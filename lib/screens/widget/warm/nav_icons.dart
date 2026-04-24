import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum NavIconKind { devices, messages, settings }

/// Filled SVG nav icons authored on a 24x24 grid and scaled to [size].
class NavIcon extends StatelessWidget {
  final NavIconKind kind;
  final double size;
  final Color color;

  const NavIcon({
    super.key,
    required this.kind,
    required this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(
        kind.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}

extension NavIconKindAsset on NavIconKind {
  String get assetPath {
    switch (this) {
      case NavIconKind.devices:
        return 'assets/icons/device.svg';
      case NavIconKind.messages:
        return 'assets/icons/messages.svg';
      case NavIconKind.settings:
        return 'assets/icons/settings.svg';
    }
  }
}
