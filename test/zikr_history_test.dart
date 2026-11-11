import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zikr/core/zikr_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:zikr/generated/app_localizations.dart';
import 'package:zikr/features/zikr/zikr_counter_page.dart';
import 'package:zikr/features/zikr/zikr_list_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zikr/core/database_service.dart';

void main() {
  final service = DatabaseService();
  late Database db;
  late Directory directory;
  late int id;
  String dateKey(DateTime date) => date.toIso8601String().split('T').first;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    directory = await Directory.systemTemp.createTemp('zikr_history_test_');
    await databaseFactory.setDatabasesPath(directory.path);
    db = await service.database;
    id = (await service.getZikrCounters()).first.id;
  });

  setUp(() async {
    await db.delete('zikr_sessions');
    await db.update('zikr_counters', {
      'sessionCount': 0,
      'lifetimeTotal': 0,
      'lastUpdated': DateTime.now().toIso8601String(),
      'lastResetDate': dateKey(DateTime.now()),
    });
  });

  tearDownAll(() async {
    await db.close();
    await directory.delete(recursive: true);
  });

  test(
    'chart includes active session and seven ordered calendar days',
    () async {
      await service.incrementZikrCount(id, 33);
      final history = await service.getDailyTotals(id);
      expect(history.length, 7);
      expect(history.keys.first, dateKey(DateTime.now()));
      expect(history.values.first, 33);
      expect(history.values.skip(1), everyElement(0));
      expect(await service.getTodayZikrTotal(id), 33);
    },
  );

  test(
    'reset preserves daily and lifetime totals without double counting',
    () async {
      await service.incrementZikrCount(id, 33);
      await service.resetZikrSession(id);
      await service.incrementZikrCount(id, 7);
      expect((await service.getDailyTotals(id)).values.first, 40);
      expect(await service.getTodayZikrTotal(id), 40);
      expect(await service.getLifetimeTotal(id), 40);
      expect((await service.getZikrSessions(id)).single.count, 33);
    },
  );

  test(
    'reopening after days archives on original activity date exactly once',
    () async {
      final old = DateTime.now().subtract(const Duration(days: 5));
      await db.update(
        'zikr_counters',
        {
          'sessionCount': 80,
          'lifetimeTotal': 80,
          'lastUpdated': old.toIso8601String(),
          'lastResetDate': dateKey(old),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await Future.wait(
        List.generate(5, (_) => service.checkAndResetDailyCount(id)),
      );
      final sessions = await service.getZikrSessions(id);
      expect(sessions.length, 1);
      expect(sessions.single.dateOnly, dateKey(old));
      expect((await service.getDailyTotals(id))[dateKey(old)], 80);
      expect(await service.getTodayZikrTotal(id), 0);
      expect(await service.getYesterdayTotalAllZikr(), 0);
      expect(await service.getLifetimeTotal(id), 80);
    },
  );

  test('rapid increments do not lose saved counts', () async {
    await Future.wait(
      List.generate(50, (_) => service.incrementZikrCount(id, 1)),
    );
    expect((await service.getZikrCounter(id))!.sessionCount, 50);
    expect(await service.getLifetimeTotal(id), 50);
  });

  test('history belongs only to selected Dhikr', () async {
    final other = (await service.getZikrCounters())[1].id;
    await service.incrementZikrCount(other, 100);
    await service.resetZikrSession(other);
    await service.incrementZikrCount(id, 5);
    expect(await service.getZikrSessions(id), isEmpty);
    expect((await service.getDailyTotals(id)).values.first, 5);
    expect((await service.getDailyTotals(other)).values.first, 100);
  });

  test(
    'home totals archive old sessions before computing today and yesterday',
    () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await db.update(
        'zikr_counters',
        {
          'sessionCount': 20,
          'lifetimeTotal': 20,
          'lastUpdated': yesterday.toIso8601String(),
          'lastResetDate': dateKey(yesterday),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(await service.getTodayTotalAllZikr(), 0);
      expect(await service.getYesterdayTotalAllZikr(), 20);
    },
  );

  testWidgets('selected Dhikr displays its dated history and lifetime total', (
    tester,
  ) async {
    final counter = await tester.runAsync(() async {
      final selected = (await service.getZikrCounters()).first;
      await service.incrementZikrCount(id, 33);
      await service.resetZikrSession(id);
      await service.incrementZikrCount(id, 7);
      final other = (await service.getZikrCounters())[1].id;
      await service.incrementZikrCount(other, 999);
      await service.resetZikrSession(other);
      return selected;
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ZikrCounterPage(
          zikr: ZikrItem(
            name: counter!.name,
            arabic: counter.arabic,
            meaning: counter.meaning,
            gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
            count: 7,
          ),
        ),
      ),
    );
    // SQLite uses real asynchronous IO outside the widget test's fake clock.
    for (
      var i = 0;
      i < 100 && find.text('Previous sessions (1)').evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(find.text('Previous sessions (1)'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);
    expect(find.text('40'), findsWidgets);
    expect(find.text('999'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('custom Dhikr saves its own count and history', () async {
    final storage = ZikrStorageService.instance;
    expect(
      await storage.addCustomZikr(
        name: 'Test custom Dhikr',
        arabic: '???',
        meaning: 'Test',
      ),
      isTrue,
    );
    expect(await storage.incrementZikrCount('Test custom Dhikr', 12), isTrue);
    expect(await storage.resetZikrSession('Test custom Dhikr'), isTrue);
    expect(
      (await storage.getZikrSessions('Test custom Dhikr')).single.count,
      12,
    );
    expect(await storage.getLifetimeTotal('Test custom Dhikr'), 12);
    expect(
      await storage.getZikrSessions((await service.getZikrCounter(id))!.name),
      isEmpty,
    );
  });

  test('custom names cannot collide with predefined Dhikr history', () async {
    final storage = ZikrStorageService.instance;
    expect(
      await storage.addCustomZikr(
        name: ZikrStorageService.predefinedZikr.first['name']!,
        arabic: '',
        meaning: '',
      ),
      isFalse,
    );
    expect(
      await storage.addCustomZikr(name: '   ', arabic: '', meaning: ''),
      isFalse,
    );
  });

  test('session history is persisted to the database file', () async {
    await service.incrementZikrCount(id, 42);
    await service.resetZikrSession(id);
    final reopened = await databaseFactory.openDatabase(
      db.path,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    try {
      final saved = await reopened.query(
        'zikr_sessions',
        where: 'zikrId = ?',
        whereArgs: [id],
      );
      expect(saved.single['count'], 42);
    } finally {
      await reopened.close();
    }
  });

  test('Quran Ruku selection persists and restores Juz 14 progress', () async {
    await db.delete('quran_progress');
    await service.saveQuranProgress(juzNumber: 14, rukuNumber: 22);
    final saved = await service.getLatestQuranProgress();
    expect(saved!.juzNumber, 14);
    expect(saved.rukuNumber, 22);
    expect(saved.ayahNumber, isNull);
    expect(
      (await service.getQuranHistory()).single.displayLocation,
      'Juz 14, Ruku 22',
    );
  });

  Future<void> waitFor(WidgetTester tester, bool Function() condition) async {
    for (var i = 0; i < 200 && !condition(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(condition(), isTrue, reason: 'Expected screen state did not load');
  }

  test(
    'list counts roll over while lifetime totals remain unchanged',
    () async {
      final old = DateTime.now().subtract(const Duration(days: 3));
      await db.update(
        'zikr_counters',
        {
          'sessionCount': 50,
          'lifetimeTotal': 80,
          'lastUpdated': old.toIso8601String(),
          'lastResetDate': dateKey(old),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      final name = (await service.getZikrCounter(id))!.name;
      final storage = ZikrStorageService.instance;
      expect((await storage.getAllZikrCounts())[name], 0);
      expect((await storage.getAllLifetimeTotals())[name], 80);
      expect((await storage.getZikrSessions(name)).single.count, 50);
    },
  );

  testWidgets('select, count rapidly, cancel reset, reset, leave and reopen', (
    tester,
  ) async {
    final name = (await tester.runAsync(
      () => service.getZikrCounter(id),
    ))!.name;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ZikrListPage(),
        routes: {
          '/zikr-counter': (context) => ZikrCounterPage(
            zikr: ModalRoute.of(context)!.settings.arguments as ZikrItem,
          ),
        },
      ),
    );
    await waitFor(tester, () => find.text(name).evaluate().isNotEmpty);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text(name));
    await tester.pump(const Duration(milliseconds: 400));
    await waitFor(
      tester,
      () => find
          .textContaining('No completed sessions yet')
          .evaluate()
          .isNotEmpty,
    );
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Tap to count'));
    }
    await waitFor(
      tester,
      () =>
          find.text('Reset Session').evaluate().isNotEmpty &&
          find.text('5').evaluate().length >= 3,
    );
    await tester.ensureVisible(find.text('Reset Session'));
    await tester.tap(find.text('Reset Session'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(await tester.runAsync(() => service.getZikrSessions(id)), isEmpty);

    await tester.tap(find.text('Reset Session'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Reset', skipOffstage: false).last);
    await tester.pump(const Duration(milliseconds: 400));
    await waitFor(
      tester,
      () => find.text('Previous sessions (1)').evaluate().isNotEmpty,
    );
    expect(
      (await tester.runAsync(() => service.getZikrSessions(id)))!.single.count,
      5,
    );
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(milliseconds: 400));
    await waitFor(
      tester,
      () =>
          find.byType(ZikrCounterPage).evaluate().isEmpty &&
          find.text(name).evaluate().length == 1,
    );
    await tester.tap(find.text(name));
    await tester.pump(const Duration(milliseconds: 400));
    await waitFor(
      tester,
      () => find.text('Previous sessions (1)').evaluate().isNotEmpty,
    );
    expect(find.text('5'), findsWidgets);
    expect(find.text('Reset Session'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final language in ['en', 'ar', 'ur']) {
    testWidgets('history renders on a small phone in $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final counter = await tester.runAsync(() async {
        await service.incrementZikrCount(id, 33);
        await service.resetZikrSession(id);
        return service.getZikrCounter(id);
      });
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ZikrCounterPage(
            zikr: ZikrItem(
              name: counter!.name,
              arabic: counter.arabic,
              meaning: counter.meaning,
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.green],
              ),
              count: 0,
            ),
          ),
        ),
      );
      await waitFor(tester, () => find.text('33').evaluate().length >= 3);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
