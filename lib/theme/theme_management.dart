import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  Color _primaryColor;

  Color get primaryColor => _primaryColor;

  ThemeProvider({Color? initialColor}) : _primaryColor = initialColor ?? Colors.amber;

  Future<void> setTheme(Color color) async {
    _primaryColor = color;
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    await pref.setInt("theme_color", color.value);
  }


}
