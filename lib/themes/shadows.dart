import 'package:flutter/painting.dart';
import 'package:simply/themes/colors.dart';

abstract class AppShadows {
  static const Color _ink = Color(0xFF281910);

  static List<BoxShadow> get s => [
        BoxShadow(
          color: _ink.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: _ink.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get m => [
        BoxShadow(
          color: _ink.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: _ink.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get l => [
        BoxShadow(
          color: _ink.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: _ink.withValues(alpha: 0.08),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ];

  static List<BoxShadow> get accent => [
        BoxShadow(
          color: AppColor.accent.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
