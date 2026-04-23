import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';

/// Letter avatar with a stable color picked from the brand palette via the
/// title hash, plus an optional device-platform badge in the corner.
class AvatarWithIndicator extends StatelessWidget {
  final String title;
  final double size;
  final String? devicePlatform;

  const AvatarWithIndicator({
    super.key,
    required this.title,
    this.size = 48,
    this.devicePlatform,
  });

  Color get _bg {
    final palette = AppColor.avatarPalette;
    final t = title.isEmpty ? 'A' : title;
    final hash = t.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return palette[hash % palette.length];
  }

  String get _letter {
    final t = title.trim();
    return t.isEmpty ? '?' : t[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final badge = _platformBadge();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _bg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _letter,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: size * 0.38,
                color: AppColor.white,
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              right: -3,
              bottom: -2,
              child: Container(
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColor.bg, width: 2),
                ),
                alignment: Alignment.center,
                child: Icon(badge, size: 11, color: AppColor.inkSecondary),
              ),
            ),
        ],
      ),
    );
  }

  IconData? _platformBadge() {
    final p = devicePlatform?.toLowerCase();
    if (p == null) return null;
    if (p.contains('ios')) return Icons.phone_iphone_rounded;
    if (p.contains('android')) return Icons.phone_android_rounded;
    return null;
  }
}
