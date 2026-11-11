import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zikr/core/database_service.dart';
import 'package:zikr/core/services/backup_service.dart';
import 'package:zikr/core/services/adhkar_service.dart';
import 'package:zikr/core/services/quran_data_service.dart';
import 'package:zikr/core/services/routine_service.dart';
import 'package:zikr/features/adhkar/adhkar_page.dart';
import 'package:zikr/features/routine/routine_page.dart';
import 'package:zikr/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = DatabaseService();
  late Database db;
  late Directory directory;
  late int id;
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    directory = await Directory.systemTemp.createTemp('dhikr_features_');
    await databaseFactory.setDatabasesPath(directory.path);
    db = await service.database;
    id = (await service.getZikrCounters()).first.id;
    await QuranDataService.instance.loadData();
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await db.delete('zikr_sessions');
    await db.delete('quran_progress');
    await db.delete('quran_completions');
    await db.update('zikr_counters', {
      'sessionCount': 0,
      'lifetimeTotal': 0,
      'lastUpdated': DateTime.now().toIso8601String(),
      'lastResetDate': dayKey(DateTime.now()),
    });
  });
  tearDownAll(() async {
    await db.close();
    await directory.delete(recursive: true);
  });

  test('planner reads real ruku data and uses inclusive calendar days', () {
    expect(QuranDataService.instance.getRukuCount(1), 16);
    expect(RoutineService.ordinal(2, 1), 17);
    expect(RoutineService.totalRukus, greaterThan(500));
    expect(
      RoutineService.daysRemaining(
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 9, 23),
      ),
      1,
    );
    expect(
      RoutineService.daysRemaining(
        DateTime(2026, 11, 10),
        DateTime(2026, 11, 9, 23),
      ),
      2,
    );
    expect(
      RoutineService.daysRemaining(
        DateTime(2026, 11, 8),
        DateTime(2026, 11, 9),
      ),
      0,
    );
  });

  test('daily Quran goal ignores duplicate locations and past dates', () async {
    await service.saveQuranProgress(juzNumber: 1, rukuNumber: 1);
    await service.saveQuranProgress(juzNumber: 1, rukuNumber: 1);
    await service.saveQuranProgress(juzNumber: 1, rukuNumber: 2);
    expect(await RoutineService.todayRukus(), 0);
    await service.markRukuCompleted(juzNumber: 1, rukuNumber: 1);
    await service.markRukuCompleted(juzNumber: 1, rukuNumber: 1);
    await service.markRukuCompleted(juzNumber: 1, rukuNumber: 2);
    expect(await RoutineService.todayRukus(), 2);
    await db.update('quran_completions', {
      'completedDate': dayKey(DateTime.now().subtract(const Duration(days: 1))),
      'completedAt': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    });
    expect(await RoutineService.todayRukus(), 0);
  });

  test(
    'backup round trip preserves sessions, counts, custom dhikr and routine',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'custom_zikr',
        jsonEncode([
          {'name': 'Personal', 'arabic': 'ذكر', 'meaning': 'Remembrance'},
        ]),
      );
      await RoutineService.save({
        'dhikrGoal': 200,
        'rukuGoal': 4,
        'reminders': false,
        'dhikrMinute': 480,
        'quranMinute': 1200,
        'finishDate': '2026-12-01',
      });
      await service.incrementZikrCount(id, 33);
      await service.resetZikrSession(id);
      await service.incrementZikrCount(id, 7);
      await service.markRukuCompleted(juzNumber: 2, rukuNumber: 3);
      final backup = await BackupService.exportJson();
      await BackupService.resetProgress();
      await prefs.remove('custom_zikr');
      await prefs.remove(RoutineService.key);
      await BackupService.restore(backup);
      expect(await service.getTodayZikrTotal(id), 40);
      expect((await service.getZikrCounter(id))!.sessionCount, 7);
      expect((await service.getQuranHistory()).single.rukuNumber, 3);
      expect((await RoutineService.settings())['dhikrGoal'], 200);
      expect(
        jsonDecode(prefs.getString('custom_zikr')!)[0]['name'],
        'Personal',
      );
    },
  );

  test(
    'backup includes custom guided lists, large targets and independent counts',
    () async {
      final collections = await AdhkarService.load();
      collections['morning']!.add(
        const AdhkarEntry(
          'Personal morning',
          '',
          'Meaning',
          '',
          500,
          id: 'custom_test',
        ),
      );
      collections['evening']!.removeWhere((entry) => entry.id == '0');
      await AdhkarService.save(collections);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AdhkarService.countsKey,
        jsonEncode({
          '${dayKey(DateTime.now())}:morning:custom_test': 150,
          '${dayKey(DateTime.now())}:evening:1': 2,
        }),
      );
      final content = await BackupService.exportJson();
      await prefs.remove(AdhkarService.collectionsKey);
      await prefs.remove(AdhkarService.countsKey);
      await BackupService.restore(content);
      final restored = await AdhkarService.load();
      expect(restored['morning']!.last.repetitions, 500);
      expect(restored['evening']!.any((entry) => entry.id == '0'), false);
      expect(
        jsonDecode(
          prefs.getString(AdhkarService.countsKey)!,
        )['${dayKey(DateTime.now())}:morning:custom_test'],
        150,
      );
      await BackupService.resetProgress();
      expect((await AdhkarService.load())['morning']!.last.id, 'custom_test');
      expect(prefs.getString(AdhkarService.countsKey), isNull);
    },
  );

  test('invalid backup cannot modify database or preferences', () async {
    await service.incrementZikrCount(id, 12);
    final backup = jsonDecode(await BackupService.exportJson());
    backup['tables']['zikr_counters'][0]['sessionCount'] = -10;
    await expectLater(
      BackupService.restore(jsonEncode(backup)),
      throwsFormatException,
    );
    expect(await service.getTodayZikrTotal(id), 12);
    final valid = await BackupService.snapshot();
    valid['tables']['zikr_sessions'] = [
      {
        'id': 1,
        'zikrId': 999999,
        'count': 10,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ];
    await expectLater(
      BackupService.restore(jsonEncode(valid)),
      throwsFormatException,
    );
    expect(await service.getTodayZikrTotal(id), 12);
  });

  test(
    'failed database restore rolls back tables and preference changes',
    () async {
      await service.incrementZikrCount(id, 15);
      await service.saveQuranProgress(juzNumber: 1, rukuNumber: 1);
      final backup = await BackupService.snapshot();
      backup['preferences']['custom_zikr'] = '[]';
      await db.execute(
        "CREATE TRIGGER reject_restore BEFORE INSERT ON quran_progress BEGIN SELECT RAISE(ABORT, 'test failure'); END",
      );
      try {
        await expectLater(
          BackupService.restore(jsonEncode(backup)),
          throwsA(isA<DatabaseException>()),
        );
        expect(await service.getTodayZikrTotal(id), 15);
        expect((await service.getQuranHistory()).length, 1);
        expect(
          (await SharedPreferences.getInstance()).getString('custom_zikr'),
          isNull,
        );
      } finally {
        await db.execute('DROP TRIGGER reject_restore');
      }
    },
  );

  test(
    'reset clears progress and guided counts while retaining configuration',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_zikr', '[]');
      await prefs.setString('adhkar_v1', '{"count":3}');
      await service.incrementZikrCount(id, 20);
      await BackupService.resetProgress();
      expect(await service.getTodayZikrTotal(id), 0);
      expect(await service.getLifetimeTotal(id), 0);
      expect(prefs.getString('custom_zikr'), '[]');
      expect(prefs.getString('adhkar_v1'), isNull);
    },
  );

  test(
    'CSV contains active and completed sessions and escapes formulas',
    () async {
      await db.update(
        'zikr_counters',
        {'name': '=formula'},
        where: 'id = ?',
        whereArgs: [id],
      );
      try {
        await service.incrementZikrCount(id, 8);
        await service.resetZikrSession(id);
        final csv = await BackupService.exportCsv();
        expect(csv, contains("'=formula"));
        expect(csv, contains('session,'));
      } finally {
        await db.update(
          'zikr_counters',
          {'name': 'test counter'},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    },
  );

  Widget app(Widget home, {String language = 'en'}) => MaterialApp(
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  testWidgets('routine validates goals before saving', (tester) async {
    await tester.pumpWidget(app(const RoutinePage()));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '0');
    await tester.ensureVisible(find.text('Save routine'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save routine'));
    await tester.pump();
    expect(
      find.text('Enter whole numbers from 1 to 1,000,000.'),
      findsOneWidget,
    );
    expect(await RoutineService.settings(), isEmpty);
  });

  testWidgets(
    'guided adhkar caps counts, persists and separates morning/evening',
    (tester) async {
      await tester.pumpWidget(app(const AdhkarPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();
      final first = find
          .byWidgetPredicate((widget) => widget is FilledButton)
          .first;
      await tester.ensureVisible(first);
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(first);
        await tester.pumpAndSettle();
      }
      expect(find.text('Completed · 3 / 3'), findsOneWidget);
      expect(tester.widget<FilledButton>(first).onPressed, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(
        jsonDecode(
          prefs.getString('adhkar_v1')!,
        )['${dayKey(DateTime.now())}:morning:0'],
        3,
      );
      await tester.drag(find.byType(ListView), const Offset(0, 1200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Evening'));
      await tester.pumpAndSettle();
      expect(find.text('Completed · 3 / 3'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Arabic routine layout fits a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const RoutinePage(), language: 'ar'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('الورد اليومي'), findsOneWidget);
  });
}
