
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController with ChangeNotifier {
  final SharedPreferences? sharedPreferences;
  ThemeController({required this.sharedPreferences}) {
    _loadCurrentTheme();
  }

  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    sharedPreferences!.setBool(AppConstants.theme, _darkTheme);
    notifyListeners();
  }

  void _loadCurrentTheme() async {
    if (sharedPreferences != null && sharedPreferences!.containsKey(AppConstants.theme)) {
      _darkTheme = sharedPreferences!.getBool(AppConstants.theme)!;
    } else {
      _darkTheme = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    notifyListeners();
  }

  Color? selectedPrimaryColor;
  Color? selectedSecondaryColor;



  void setThemeColor({Color? primaryColor, Color? secondaryColor}) {
    selectedPrimaryColor = primaryColor;
    selectedSecondaryColor = secondaryColor;

    notifyListeners();
  }



}
