import 'package:flutter/material.dart';

abstract final class AllineSpacing {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32;
  static const double contentMaxWidth = 600;
}

abstract final class AllineRadius {
  static const double control = 12, card = 16, hero = 24;
  static const cardBorder = BorderRadius.all(Radius.circular(card));
}
