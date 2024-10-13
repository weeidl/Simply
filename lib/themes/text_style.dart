import 'package:flutter/painting.dart';

abstract class AppTextStyle {
  static const letterSpacing = null;

  static TextStyle display(Color color) {
    return TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle displayAccent(Color color) {
    return TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle title1Accent(Color color) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle title1(Color color) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle title2(Color color) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle title3(Color color) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle title5(Color color) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle titleAccent3(Color color) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle title4(Color color) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle paragraph(Color color) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle paragraphM(Color color) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle paragraphB(Color color) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle captionB(Color color) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle captionM(Color color) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle captionSM(Color color) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle captionSM3(Color color) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle captionS(Color color) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle captionSC(Color color) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle captionSC4(Color color) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
