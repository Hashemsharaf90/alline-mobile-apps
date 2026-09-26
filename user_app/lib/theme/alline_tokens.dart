import 'package:flutter/material.dart';

abstract final class AllineSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double hero = 48;
  static const double screen = 64;
}

abstract final class AllineRadius {
  static const double small = 8;
  static const double control = 12;
  static const double input = 14;
  static const double button = 16;
  static const double card = 16;
  static const double cardLarge = 20;
  static const double hero = 24;
  static const double pill = 999;
}

abstract final class AllineDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
}

abstract final class AllineTouchTarget {
  static const double minimum = 44;
  static const double buttonHeight = 54;
  static const Size minimumSize = Size(44, 44);
}
