import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simply/l10n/app_localizations.dart';
import 'package:simply/screens/widget/warm/warm_bottom_dock.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

enum WarmToastKind { success, info, error, copy }

/// Lightweight toast rendered as an [OverlayEntry] in the root overlay,
/// styled as a navbar-extension banner via [WarmDockedSurface].
///
/// Position: docks flush above the bottom navbar when [WarmBottomDock] is
/// present in the caller's context (read at [show] time, before insertion
/// into the root overlay so the InheritedWidget is reachable). When no
/// dock is present, the banner anchors to the screen bottom and pads its
/// content above the safe-area inset while the banner fill extends down to
/// the screen edge — preventing a white strip behind the iOS home
/// indicator.
class WarmToast {
  WarmToast._();

  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String message,
    WarmToastKind kind = WarmToastKind.success,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 1800),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final dockOffset = WarmBottomDock.offsetOf(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    _dismiss();

    final entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        icon: icon ?? _defaultIcon(kind),
        kind: kind,
        duration: duration,
        dockOffset: dockOffset,
        safeAreaBottom: bottomInset,
        onDone: _dismiss,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void copied(BuildContext context, [String? message]) {
    show(
      context,
      message: message ?? AppLocalizations.of(context)!.copied,
      kind: WarmToastKind.copy,
      duration: const Duration(milliseconds: 1400),
    );
  }

  static void success(BuildContext context, String message, {IconData? icon}) =>
      show(
        context,
        message: message,
        kind: WarmToastKind.success,
        icon: icon,
      );

  static void error(BuildContext context, String message) => show(
        context,
        message: message,
        kind: WarmToastKind.error,
        duration: const Duration(milliseconds: 2600),
      );

  static void info(BuildContext context, String message) =>
      show(context, message: message, kind: WarmToastKind.info);

  static void dismiss() => _dismiss();

  static IconData _defaultIcon(WarmToastKind kind) {
    switch (kind) {
      case WarmToastKind.success:
      case WarmToastKind.copy:
        return Icons.check_rounded;
      case WarmToastKind.info:
        return Icons.info_outline_rounded;
      case WarmToastKind.error:
        return Icons.error_outline_rounded;
    }
  }

  static void _dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _ToastView extends StatefulWidget {
  final String message;
  final IconData icon;
  final WarmToastKind kind;
  final Duration duration;
  final double dockOffset;
  final double safeAreaBottom;
  final VoidCallback onDone;

  const _ToastView({
    required this.message,
    required this.icon,
    required this.kind,
    required this.duration,
    required this.dockOffset,
    required this.safeAreaBottom,
    required this.onDone,
  });

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _dismissTimer;

  bool get _isIOS => Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isIOS ? 380 : 260),
      reverseDuration: Duration(milliseconds: _isIOS ? 240 : 200),
    );
    final entry = CurvedAnimation(
      parent: _ctrl,
      curve: _isIOS ? Curves.easeOutCubic : Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(entry);

    _ctrl.forward();

    _dismissTimer = Timer(widget.duration, () async {
      if (!mounted) return;
      await _ctrl.reverse();
      if (!mounted) return;
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  (Color foreground, Color iconBg) get _palette {
    switch (widget.kind) {
      case WarmToastKind.success:
      case WarmToastKind.copy:
        return (AppColor.accentDeep, AppColor.accentSoft);
      case WarmToastKind.info:
        return (AppColor.inkSecondary, AppColor.bgAlt);
      case WarmToastKind.error:
        return (AppColor.danger, AppColor.danger.withValues(alpha: 0.14));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fg, iconBg) = _palette;
    final isDocked = widget.dockOffset > 0;
    // Without an external dock, pad content above the home indicator while
    // letting the surface fill cover the safe area beneath it.
    final extraBottomPadding = isDocked ? 0.0 : widget.safeAreaBottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.dockOffset,
      child: IgnorePointer(
        child: ClipRect(
          // Allow upward shadow to escape; clip the slide-out below the
          // surface so the banner cleanly disappears behind the navbar
          // (or beneath the screen edge when no dock is present) without
          // bleeding over it.
          clipper: const _BannerClipper(),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: WarmDockedSurface(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                extraBottomPadding: extraBottomPadding,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(widget.icon, size: 15, color: fg),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodySmBold(AppColor.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets the banner's upward shadow extend above the surface but clips any
/// slide-translated overflow at the bottom edge — keeping a clean exit
/// behind the navbar / off the screen during dismiss.
class _BannerClipper extends CustomClipper<Rect> {
  const _BannerClipper();

  @override
  Rect getClip(Size size) {
    const shadowExtent = 48.0;
    return Rect.fromLTRB(
      -shadowExtent,
      -shadowExtent,
      size.width + shadowExtent,
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
