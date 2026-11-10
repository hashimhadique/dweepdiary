import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeKey = 'app_theme_mode';
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString(_themeKey);
      if (mode == 'dark') {
        themeModeNotifier.value = ThemeMode.dark;
      } else {
        // Default strictly to Light (Day) Mode for all new installs
        themeModeNotifier.value = ThemeMode.light;
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    themeModeNotifier.value = newMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }
}
