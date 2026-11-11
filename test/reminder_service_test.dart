import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikr/core/services/reminder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  const zone = MethodChannel('flutter_timezone');
  final calls = <MethodCall>[];
  late ReminderService service;
  bool allowed = true;
  final config = <String, dynamic>{
    'reminders': true,
    'dhikrMinute': 480,
    'quranMinute': 1200,
  };
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    service = ReminderService();
    calls.clear();
    allowed = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(zone, (call) async => 'Asia/Kolkata');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'requestNotificationsPermission' ||
              call.method == 'areNotificationsEnabled') {
            return allowed;
          }
          if (call.method == 'initialize') return true;
          return null;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(zone, null);
  });

  test('schedules two distinct daily reminders in device timezone', () async {
    expect(await service.schedule(config, requestPermission: true), isTrue);
    final schedules = calls
        .where((call) => call.method == 'zonedSchedule')
        .toList();
    expect(schedules.length, 2);
    expect(schedules.map((c) => c.arguments['id']), [100, 101]);
    expect(schedules.first.arguments['timeZoneName'], 'Asia/Kolkata');
    expect(
      schedules.first.arguments['scheduledDateTime'],
      contains('T08:00:00'),
    );
    expect(
      schedules.last.arguments['scheduledDateTime'],
      contains('T20:00:00'),
    );
    expect(schedules.first.arguments['matchDateTimeComponents'], 0);
    final now = DateTime.now();
    final next = DateTime.parse(
      '${schedules.first.arguments['scheduledDateTime']}+05:30',
    );
    expect(next.isAfter(now), isTrue);
    expect(next.difference(now), lessThanOrEqualTo(const Duration(hours: 24)));
  });
  test(
    'denied permission cancels old reminders and schedules nothing',
    () async {
      allowed = false;
      expect(await service.schedule(config, requestPermission: true), isFalse);
      expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
      expect(calls.where((c) => c.method == 'cancel').length, 2);
    },
  );
  test('turning reminders off cancels without asking for permission', () async {
    expect(await service.schedule({'reminders': false}), isTrue);
    expect(calls.where((c) => c.method == 'cancel').length, 2);
    expect(
      calls.where((c) => c.method == 'requestNotificationsPermission'),
      isEmpty,
    );
  });
  test('resume checks permission without prompting again', () async {
    await service.schedule(config);
    expect(calls.where((c) => c.method == 'areNotificationsEnabled').length, 1);
    expect(
      calls.where((c) => c.method == 'requestNotificationsPermission'),
      isEmpty,
    );
  });
}
