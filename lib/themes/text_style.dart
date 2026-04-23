import 'package:flutter/painting.dart';

/// Manrope-based typography scale matching the Simply hi-fi design.
///
/// Naming: `display`, `h1`, `title`, `body`, `bodySm`, `caption`, `captionUpper`.
/// Each accepts a color so screens compose with their local palette.
abstract class AppTextStyle {
  static const String _family = 'Manrope';

  static TextStyle display(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.7,
        height: 1.05,
      );

  static TextStyle h1(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle title(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle titleSm(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle body(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle bodyM(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: -0.2,
        height: 1.45,
      );

  static TextStyle bodySm(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle bodySmBold(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle caption(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle captionUpper(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.8,
      );

  static TextStyle micro(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.4,
      );

  static TextStyle button(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.2,
      );

  /// Monospaced display for OTP codes.
  static TextStyle codeMono(Color color) => TextStyle(
        fontFamily: _family,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 3,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
