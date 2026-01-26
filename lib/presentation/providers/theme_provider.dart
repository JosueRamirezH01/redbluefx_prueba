import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    if (saved == 'dark') {
      state = ThemeMode.dark;
    }else if (saved == 'light'){
      state = ThemeMode.light;
    }else {
      state = ThemeMode.light;
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'themeMode',
      state == ThemeMode.dark
          ? 'dark'
          : state == ThemeMode.light
          ? 'light'
          : 'light',
    );
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveTheme();
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _saveTheme();
  }
}
