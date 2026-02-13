import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  static LocaleService? _instance;
  static LocaleService get instance => _instance ??= LocaleService._();
  
  LocaleService._();
  
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
    Locale('ur'), // Urdu
  ];
  
  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey) ?? 'en';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      print('Error loading locale: $e');
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      notifyListeners();
    } catch (e) {
      print('Error saving locale: $e');
    }
  }
  
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ur':
        return 'اردو';
      default:
        return 'English';
    }
  }
}
