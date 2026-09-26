import 'package:flutter/material.dart';
import 'home_screens.dart';
export 'home_screens.dart' show SliverDelegate, SliverSearchDelegate;

/// Alline shares one discovery layout across the supported storefront themes.
class AsterThemeHomeScreen extends StatelessWidget {
  const AsterThemeHomeScreen({super.key});
  static Future<void> loadData(bool reload) => HomePage.loadData(reload);
  @override
  Widget build(BuildContext context) => const HomePage();
}
