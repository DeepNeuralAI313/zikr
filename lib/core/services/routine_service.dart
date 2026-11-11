import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_service.dart';
import 'quran_data_service.dart';
import 'locale_service.dart';

String dayKey(DateTime value) => value.toIso8601String().split('T').first;

class RoutineService {
  static const key = 'daily_routine_v1';
  static final changes = ValueNotifier<int>(0);
  static const widgetChannel = MethodChannel('dhikr/widget');
  static Timer? _widgetTimer;
  static void progressChanged() {
    changes.value++;
    _widgetTimer?.cancel();
    _widgetTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        await updateWidget();
      } catch (e) {
        debugPrint('Widget refresh failed: $e');
      }
    });
  }

  static Future<Map<String, dynamic>> settings() async {
    final prefs = await SharedPreferences.getInstance();
    return jsonDecode(prefs.getString(key) ?? '{}') as Map<String, dynamic>;
  }

  static Future<void> save(Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(key, jsonEncode(value))) {
      throw StateError('Could not save your routine');
    }
    changes.value++;
    await updateWidget();
  }

  static int ordinal(int juz, int ruku) {
    final data = QuranDataService.instance;
    return List.generate(
          juz - 1,
          (i) => data.getRukuCount(i + 1),
        ).fold<int>(0, (a, b) => a + b) +
        ruku;
  }

  static int get totalRukus => List.generate(
    30,
    (i) => QuranDataService.instance.getRukuCount(i + 1),
  ).fold<int>(0, (a, b) => a + b);

  /// Only explicit completions count; bookmarks never add reading credit.
  static Future<int> todayRukus() async => (await DatabaseService()
      .completedRukuKeys(date: dayKey(DateTime.now()))).length;

  static int daysRemaining(DateTime finish, DateTime now) {
    final start = DateTime.utc(now.year, now.month, now.day);
    final end = DateTime.utc(finish.year, finish.month, finish.day);
    return end.difference(start).inDays + 1;
  }

  static Future<void> updateWidget() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final config = await settings();
      await widgetChannel.invokeMethod('update', {
        'date': dayKey(DateTime.now()),
        'language': LocaleService.instance.locale.languageCode,
        'dhikr': await DatabaseService().getTodayTotalAllZikr(),
        'rukus': await todayRukus(),
        'dhikrGoal': config['dhikrGoal'] ?? 100,
        'rukuGoal': config['rukuGoal'] ?? 2,
      });
    } on MissingPluginException {
      // Flutter tests do not load the Android widget host.
    } on PlatformException catch (error) {
      debugPrint('Widget refresh failed: $error');
    }
  }
}
