import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';

/// Exposes the screen-bottom Y offset where dockable banners (selection
/// action bar, toasts) should align their bottom edge.
///
/// Set this once at the screen scaffolding level. When a [PillTabBar] is
/// present, set [offset] to its visible height including the bottom safe
/// inset; consumers can then position with `bottom: offset` and the banner
/// will sit flush above the navbar. Screens without a bottom navbar simply
/// don't provide this widget — [offsetOf] returns `0` and banners dock to
/// the screen bottom edge instead.
class WarmBottomDock extends InheritedWidget {
  final double offset;

  const WarmBottomDock({
    super.key,
    required this.offset,
    required super.child,
  });

  static double offsetOf(BuildContext context) {
    final dock = context.dependOnInheritedWidgetOfExactType<WarmBottomDock>();
    return dock?.offset ?? 0;
  }

  @override
  bool updateShouldNotify(WarmBottomDock oldWidget) =>
      oldWidget.offset != offset;
}

/// Shared visual surface for banners that "extend" the navbar from above.
///
/// Mirrors the navbar's styling (same fill, same hairline top divider, same
/// upward shadows, no border radius) so a banner placed at
/// `WarmBottomDock.offsetOf(context)` reads as one continuous stack with the
/// navbar below it.
///
/// When the host screen has no bottom navbar (dock offset is `0`), the
/// banner sits at the screen's bottom edge instead. In that mode, the
/// caller should pass [extraBottomPadding] equal to the bottom safe inset
/// so the surface fill covers the iOS home indicator area while keeping
/// content above it — preventing the white strip from showing through.
class WarmDockedSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double extraBottomPadding;

  const WarmDockedSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(12, 10, 12, 10),
    this.extraBottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding.copyWith(bottom: padding.bottom + extraBottomPadding),
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
      child: child,
    );
  }
}
