import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';

/// On iOS we add a subtle scale-down on press (the native-feeling "squish"
/// Cupertino buttons use). On Android we stay out of the way and let the
/// platform ripple do the work — iOS receivers lean on polish, Android
/// senders must stay lean since they run background SMS work.
///
/// Wraps any interactive child. Use with `InkWell`/`GestureDetector` that
/// already provide the actual `onTap`; this widget only supplies the
/// pressed-feedback animation.
class PlatformTapScale extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double pressedScale;

  /// When set, overrides the platform check. Mainly for tests.
  @visibleForTesting
  final bool? forceEnabled;

  const PlatformTapScale({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 140),
    this.pressedScale = 0.96,
    this.forceEnabled,
  });

  @override
  State<PlatformTapScale> createState() => _PlatformTapScaleState();
}

class _PlatformTapScaleState extends State<PlatformTapScale> {
  bool _pressed = false;

  bool get _enabled => widget.forceEnabled ?? Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Platform-aware page transition. Uses `CupertinoPageRoute` on iOS for the
/// native swipe-back + slide-in; falls back to `MaterialPageRoute` elsewhere.
Route<T> platformPageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool fullscreenDialog = false,
}) {
  if (Platform.isIOS) {
    return CupertinoPageRoute<T>(
      builder: builder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }
  return MaterialPageRoute<T>(
    builder: builder,
    settings: settings,
    fullscreenDialog: fullscreenDialog,
  );
}
