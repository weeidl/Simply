import 'package:flutter/material.dart';
import 'package:simply/screens/widget/warm/nav_icons.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

class PillTab {
  final NavIconKind kind;
  final String label;

  const PillTab({required this.kind, required this.label});
}

/// Edge-to-edge bottom navigation. The active tab inflates into a coral pill
/// hugging its icon + label; inactive tabs collapse to icon-only. Color and
/// pill width share one ease-out cubic transition; the icon scale rides an
/// overshoot curve for a subtle pop on activation.
class PillTabBar extends StatelessWidget {
  final List<PillTab> tabs;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  static const Duration _duration = Duration(milliseconds: 380);
  static const Curve _curve = Curves.easeOutCubic;
  static const Curve _popCurve = Curves.easeOutBack;
  static const double _rowHeight = 60;
  static const double _itemHorizontalPadding = 18;
  static const double _labelLeftPadding = 4;
  static const double _iconSize = 24;
  static const double _minLabelFontSize = 12;

  const PillTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.navBar,
        border: const Border(
          top: BorderSide(color: AppColor.divider, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF281910).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: const Color(0xFF281910).withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final labelFontSize = _resolveUniformLabelFontSize(
                context,
                constraints.maxWidth,
              );
              return SizedBox(
                height: _rowHeight,
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    return Expanded(
                      child: _PillTabItem(
                        tab: tabs[i],
                        active: i == activeIndex,
                        onTap: () => onChanged(i),
                        duration: _duration,
                        curve: _curve,
                        popCurve: _popCurve,
                        labelFontSize: labelFontSize,
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _resolveUniformLabelFontSize(
    BuildContext context,
    double navBarWidth,
  ) {
    final baseStyle = AppTextStyle.titleSm(AppColor.accent);
    final baseFontSize = baseStyle.fontSize ?? 16;
    final tabWidth = navBarWidth / tabs.length;
    final maxLabelWidth = tabWidth -
        (_itemHorizontalPadding * 2) -
        _iconSize -
        _labelLeftPadding;
    if (maxLabelWidth <= 0) return _minLabelFontSize;

    final textScaler = MediaQuery.textScalerOf(context);
    var scale = 1.0;
    for (final tab in tabs) {
      final painter = TextPainter(
        text: TextSpan(text: tab.label, style: baseStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout();
      final width = painter.width;
      if (width <= 0) continue;
      final candidate = maxLabelWidth / width;
      if (candidate < scale) scale = candidate;
    }
    final resolved = baseFontSize * scale.clamp(0.0, 1.0);
    return resolved < _minLabelFontSize ? _minLabelFontSize : resolved;
  }
}

class _PillTabItem extends StatelessWidget {
  final PillTab tab;
  final bool active;
  final VoidCallback onTap;
  final Duration duration;
  final Curve curve;
  final Curve popCurve;
  final double labelFontSize;

  const _PillTabItem({
    required this.tab,
    required this.active,
    required this.onTap,
    required this.duration,
    required this.curve,
    required this.popCurve,
    required this.labelFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final pillColor =
        active ? AppColor.accentSoft : AppColor.accentSoft.withValues(alpha: 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Semantics(
          button: true,
          selected: active,
          label: tab.label,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppRadii.brPill,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: onTap,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    height: 52,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: AppRadii.brPill,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedIcon(
                          kind: tab.kind,
                          active: active,
                          duration: duration,
                          curve: curve,
                          popCurve: popCurve,
                        ),
                        Flexible(
                          child: ClipRect(
                            child: AnimatedAlign(
                              duration: duration,
                              curve: curve,
                              alignment: Alignment.centerLeft,
                              widthFactor: active ? 1 : 0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: AnimatedOpacity(
                                  duration: duration,
                                  curve: curve,
                                  opacity: active ? 1 : 0,
                                  child: Text(
                                    tab.label,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                    style: AppTextStyle.titleSm(
                                      AppColor.accent,
                                    ).copyWith(fontSize: labelFontSize),
                                  ),
                                ),
                              ),
                            ),
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
      },
    );
  }
}

/// Icon with two synchronized animations: a smooth color lerp for selection
/// and an overshoot scale pop (1.0 → ~1.12) so activation feels tactile.
class _AnimatedIcon extends StatelessWidget {
  final NavIconKind kind;
  final bool active;
  final Duration duration;
  final Curve curve;
  final Curve popCurve;

  const _AnimatedIcon({
    required this.kind,
    required this.active,
    required this.duration,
    required this.curve,
    required this.popCurve,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: popCurve,
      tween: Tween<double>(end: active ? 1 : 0),
      builder: (_, pop, __) {
        final scale = 1 + 0.12 * pop;
        return Transform.scale(
          scale: scale,
          child: TweenAnimationBuilder<double>(
            duration: duration,
            curve: curve,
            tween: Tween<double>(end: active ? 1 : 0),
            builder: (_, t, __) {
              final clamped = t.clamp(0.0, 1.0);
              final color = Color.lerp(
                AppColor.inkTertiary,
                AppColor.accent,
                clamped,
              )!;
              return NavIcon(
                kind: kind,
                size: 24,
                color: color,
              );
            },
          ),
        );
      },
    );
  }
}
