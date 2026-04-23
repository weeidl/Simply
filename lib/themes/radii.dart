import 'package:flutter/widgets.dart';

abstract class AppRadii {
  static const double r1 = 12;
  static const double r2 = 16;
  static const double r3 = 20;
  static const double r4 = 28;
  static const double r5 = 36;
  static const double pill = 999;

  static const BorderRadius brR1 = BorderRadius.all(Radius.circular(r1));
  static const BorderRadius brR2 = BorderRadius.all(Radius.circular(r2));
  static const BorderRadius brR3 = BorderRadius.all(Radius.circular(r3));
  static const BorderRadius brR4 = BorderRadius.all(Radius.circular(r4));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}
