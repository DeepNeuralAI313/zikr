import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  static ThemeService? _instance;
  static ThemeService get instance => _instance ??= ThemeService._();
  
  ThemeService._();
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
      notifyListeners();
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
  
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
      notifyListeners();
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
}
