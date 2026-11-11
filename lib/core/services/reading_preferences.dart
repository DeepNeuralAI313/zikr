import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingPreferences extends ChangeNotifier {
  static final instance = ReadingPreferences();
  static const key = 'reading_preferences_v1';
  static const defaults = <String, dynamic>{
    'arabicSize': 26.0,
    'meaningSize': 16.0,
    'showTransliteration': true,
    'meaningLanguage': 'auto',
  };
  Map<String, dynamic> _values = Map.of(defaults);
  double get arabicSize => (_values['arabicSize'] as num).toDouble();
  double get meaningSize => (_values['meaningSize'] as num).toDouble();
  bool get showTransliteration => _values['showTransliteration'] as bool;
  String get meaningLanguage => _values['meaningLanguage'] as String;
  bool useUrdu(String locale) =>
      meaningLanguage == 'ur' || meaningLanguage == 'auto' && locale == 'ur';

  static Map<String, dynamic> decode(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid reading preferences');
    }
    final values = decoded;
    if (values['arabicSize'] is! num ||
        values['arabicSize'] < 20 ||
        values['arabicSize'] > 44 ||
        values['meaningSize'] is! num ||
        values['meaningSize'] < 12 ||
        values['meaningSize'] > 26 ||
        values['showTransliteration'] is! bool ||
        !['auto', 'en', 'ur'].contains(values['meaningLanguage'])) {
      throw const FormatException('Invalid reading preferences');
    }
    return values;
  }

  Future<void> load() async {
    final encoded = (await SharedPreferences.getInstance()).getString(key);
    try {
      _values = encoded == null ? Map.of(defaults) : decode(encoded);
    } on FormatException {
      _values = Map.of(defaults);
    }
    notifyListeners();
  }

  Future<void> save({
    double? arabicSize,
    double? meaningSize,
    bool? showTransliteration,
    String? meaningLanguage,
  }) async {
    final values = {
      ..._values,
      if (arabicSize != null) 'arabicSize': arabicSize,
      if (meaningSize != null) 'meaningSize': meaningSize,
      if (showTransliteration != null)
        'showTransliteration': showTransliteration,
      if (meaningLanguage != null) 'meaningLanguage': meaningLanguage,
    };
    final encoded = jsonEncode(values);
    decode(encoded);
    if (!await (await SharedPreferences.getInstance()).setString(
      key,
      encoded,
    )) {
      throw StateError('Could not save reading preferences');
    }
    _values = values;
    notifyListeners();
  }
}
