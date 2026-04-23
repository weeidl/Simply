import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';

/// Warm background scaffold. The new design uses a single flat warm surface
/// (no white top sheet), so this just gives every screen a consistent base.
class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final Widget? appBar;
  final Widget? bottomBar;
  final EdgeInsetsGeometry padding;

  const BackgroundWidget({
    super.key,
    required this.child,
    this.appBar,
    this.bottomBar,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (appBar != null) appBar!,
            Expanded(
              child: Padding(padding: padding, child: child),
            ),
            if (bottomBar != null) bottomBar!,
          ],
        ),
      ),
    );
  }
}
