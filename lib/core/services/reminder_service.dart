import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../generated/app_localizations.dart';
import 'locale_service.dart';

class ReminderService {
  static final instance = ReminderService();
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (!supported) return;
    tzdata.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    if (_ready) return;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  Future<bool> schedule(
    Map<String, dynamic> config, {
    bool requestPermission = false,
  }) async {
    if (!supported) return false;
    await initialize();
    if (config['reminders'] != true) {
      await _plugin.cancel(100);
      await _plugin.cancel(101);
      return true;
    }
    bool allowed = true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      allowed =
          (requestPermission
              ? await android.requestNotificationsPermission()
              : await android.areNotificationsEnabled()) ??
          false;
    } else if (requestPermission) {
      allowed =
          await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (!allowed) {
      await _plugin.cancel(100);
      await _plugin.cancel(101);
      return false;
    }
    final l = lookupAppLocalizations(LocaleService.instance.locale);
    for (final item in [
      (100, 'dhikrMinute', 480, l.dhikrReminder),
      (101, 'quranMinute', 1200, l.quranReminder),
    ]) {
      final minutes = config[item.$2] as int? ?? item.$3;
      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        minutes ~/ 60,
        minutes % 60,
      );
      if (!next.isAfter(now)) {
        next = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + 1,
          minutes ~/ 60,
          minutes % 60,
        );
      }
      await _plugin.zonedSchedule(
        item.$1,
        item.$4,
        l.goalsAndReminders,
        next,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_routine',
            'Daily routine',
            channelDescription: 'Your chosen dhikr and Quran reminders',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    return true;
  }
}
