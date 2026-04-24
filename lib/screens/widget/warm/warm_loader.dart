import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

/// Branded inline spinner used across the app. On iOS we render Cupertino's
/// native activity indicator tinted warm; on Android we use a material
/// circular progress so the stroke weight matches platform expectations.
class WarmLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const WarmLoader({
    super.key,
    this.size = 22,
    this.color,
    this.strokeWidth = 2.6,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColor.accent;
    if (Platform.isIOS) {
      return SizedBox(
        width: size,
        height: size,
        child: CupertinoActivityIndicator(color: tint, radius: size * 0.42),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: tint,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}

/// Three orbiting warm dots — used when a page is fully blocked on an
/// initial load so the screen has some personality instead of a bare spinner.
/// Kept intentionally simple — the animation stays cheap (one controller,
/// three transforms) so it doesn't cost frames on low-end Android.
class WarmPulseDots extends StatefulWidget {
  final Color? color;
  final double dotSize;

  const WarmPulseDots({
    super.key,
    this.color,
    this.dotSize = 8,
  });

  @override
  State<WarmPulseDots> createState() => _WarmPulseDotsState();
}

class _WarmPulseDotsState extends State<WarmPulseDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColor.accent;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value - i * 0.16) % 1.0;
            final sinValue = math.sin(phase * math.pi).clamp(0, 1).toDouble();
            final scale = 0.55 + 0.45 * sinValue;
            final opacity = 0.35 + 0.65 * sinValue;
            return Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : 6),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Full-screen blocking overlay shown during long async work (e.g. auth
/// flows that the button-inline loader can't cover). Always pair with a
/// dismiss in a `finally` so it's not left on screen if the caller throws.
class WarmLoadingOverlay {
  WarmLoadingOverlay._();

  static OverlayEntry? _entry;

  static void show(BuildContext context, {String? label}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    hide();
    final entry = OverlayEntry(builder: (_) => _OverlayView(label: label));
    _entry = entry;
    overlay.insert(entry);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _OverlayView extends StatefulWidget {
  final String? label;
  const _OverlayView({this.label});

  @override
  State<_OverlayView> createState() => _OverlayViewState();
}

class _OverlayViewState extends State<_OverlayView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: Platform.isIOS ? 360 : 220),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  late final Animation<double> _scale = Tween<double>(
    begin: Platform.isIOS ? 0.86 : 0.94,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: Platform.isIOS ? Curves.easeOutBack : Curves.easeOutCubic,
  ));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _fade,
        child: ColoredBox(
          color: AppColor.black.withValues(alpha: 0.32),
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: AppRadii.brR3,
                  boxShadow: AppShadows.l,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const WarmLoader(size: 32),
                    if (widget.label != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        widget.label!,
                        style: AppTextStyle.bodySmBold(AppColor.inkSecondary),
                      ),
                    ],
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
