import 'dart:ui';

/// Simply warm coral palette.
///
/// Semantic naming: brand → surfaces → text → status. Don't reach for raw hex
/// values from screens — pick the closest semantic token here.
abstract class AppColor {
  // Brand
  static const Color accent = Color(0xFFF59B7E);
  static const Color accentDeep = Color(0xFFE87A58);
  static const Color accentSoft = Color(0xFFFEE6DC);
  static const Color accentInk = Color(0xFF5A2A18);

  // Surfaces (warm neutrals)
  static const Color bg = Color(0xFFFAF6F2);
  static const Color bgAlt = Color(0xFFF3ECE4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0x0F281910);

  // Text
  static const Color ink = Color(0xFF1D1410);
  static const Color inkSecondary = Color(0xFF4A3B32);
  static const Color inkTertiary = Color(0xFF8B7A6F);
  static const Color inkPlaceholder = Color(0xFFBFAE9F);

  // Status
  static const Color success = Color(0xFF3BB879);
  static const Color successSoft = Color(0xFFE2F5EB);
  static const Color amber = Color(0xFFE8A84A);
  static const Color danger = Color(0xFFE3563D);

  // Common
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0D0806);

  // Avatar palette — used to pick a stable color from a string hash.
  static const List<Color> avatarPalette = [
    Color(0xFFF59B7E),
    Color(0xFFB794E8),
    Color(0xFFF2B96E),
    Color(0xFF3BB879),
    Color(0xFF6B5BFF),
    Color(0xFFF28F8F),
    Color(0xFFE8734A),
    Color(0xFF3B6BE8),
  ];
}
