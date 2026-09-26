import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_theme.dart';

/// Backward-compatible entry point used by the application shell.
/// Brand colors are intentionally controlled by [AllineTheme].
ThemeData light({Color? primaryColor, Color? secondaryColor}) =>
    AllineTheme.light;
