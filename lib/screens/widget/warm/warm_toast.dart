import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

enum WarmToastKind { success, info, error, copy }

/// Lightweight floating toast rendered as an [OverlayEntry].
///
/// Chosen over [ScaffoldMessenger.showSnackBar] because the latter can't fully
/// customize entry/exit curves — we want a spring on iOS and a tighter
/// easeOutCubic on Android. Only one toast is visible at a time; calling
/// [show] while another is on screen dismisses the previous one.
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
    _dismiss();

    final entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        icon: icon ?? _defaultIcon(kind),
        kind: kind,
        duration: duration,
        onDone: _dismiss,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void copied(BuildContext context, [String? message]) {
    show(
      context,
      message: message ?? 'Скопировано',
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
  final VoidCallback onDone;

  const _ToastView({
    required this.message,
    required this.icon,
    required this.kind,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  Timer? _dismissTimer;

  bool get _isIOS => Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isIOS ? 420 : 260),
      reverseDuration: Duration(milliseconds: _isIOS ? 220 : 180),
    );
    final enter = CurvedAnimation(
      parent: _ctrl,
      curve: _isIOS ? Curves.easeOutBack : Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.55));
    _scale =
        Tween<double>(begin: _isIOS ? 0.82 : 0.94, end: 1.0).animate(enter);
    _slide = Tween<Offset>(begin: const Offset(0, 0.45), end: Offset.zero)
        .animate(enter);

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
    final mq = MediaQuery.of(context);
    final (fg, iconBg) = _palette;

    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: mq.padding.bottom + 96,
              left: 24,
              right: 24,
            ),
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  alignment: Alignment.bottomCenter,
                  child: _Pill(
                    message: widget.message,
                    icon: widget.icon,
                    fg: fg,
                    iconBg: iconBg,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color fg;
  final Color iconBg;

  const _Pill({
    required this.message,
    required this.icon,
    required this.fg,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: AppRadii.brPill,
          boxShadow: AppShadows.m,
          border: Border.all(color: AppColor.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 15, color: fg),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmBold(AppColor.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
