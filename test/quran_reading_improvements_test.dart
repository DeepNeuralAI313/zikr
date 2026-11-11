import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zikr/core/database_service.dart';
import 'package:zikr/core/models.dart';
import 'package:zikr/core/services/adhkar_service.dart';
import 'package:zikr/core/services/backup_service.dart';
import 'package:zikr/core/services/quran_data_service.dart';
import 'package:zikr/core/services/reading_preferences.dart';
import 'package:zikr/core/services/routine_service.dart';
import 'package:zikr/features/quran/ruku_selection_page.dart';
import 'package:zikr/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = DatabaseService();
  late Directory directory;
  late Database db;
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    directory = await Directory.systemTemp.createTemp('dhikr_reading_upgrade_');
    await databaseFactory.setDatabasesPath(directory.path);
    // A real version-4 database fixture verifies the upgrade preserves user data.
    final old = await databaseFactory.openDatabase(
      path.join(directory.path, 'zikr_quran.db'),
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE quran_progress(id INTEGER PRIMARY KEY AUTOINCREMENT, juzNumber INTEGER NOT NULL, rukuNumber INTEGER NOT NULL, ayahNumber INTEGER, location TEXT NOT NULL, timestamp TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE zikr_counters(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, arabic TEXT NOT NULL, meaning TEXT NOT NULL, sessionCount INTEGER NOT NULL, lifetimeTotal INTEGER NOT NULL, target INTEGER NOT NULL, lastUpdated TEXT NOT NULL, lastResetDate TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE zikr_sessions(id INTEGER PRIMARY KEY AUTOINCREMENT, zikrId INTEGER NOT NULL, count INTEGER NOT NULL, timestamp TEXT NOT NULL)',
          );
          await db.insert(
            'zikr_counters',
            ZikrCounter(
              id: 77,
              name: 'Legacy custom',
              arabic: 'ذكر',
              meaning: 'Remembrance',
              sessionCount: 12,
              lifetimeTotal: 99,
              target: 100,
              lastUpdated: DateTime.now(),
              lastResetDate: dayKey(DateTime.now()),
            ).toMap(),
          );
          await db.insert(
            'quran_progress',
            QuranProgress(
              juzNumber: 14,
              rukuNumber: 22,
              location: 'Juz 14, Ruku 22',
              timestamp: DateTime(2026, 1, 1),
            ).toMap(),
          );
        },
      ),
    );
    await old.close();
    db = await service.database;
    await QuranDataService.instance.loadData();
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await db.delete('quran_completions');
    await ReadingPreferences.instance.load();
  });
  tearDownAll(() async {
    await db.close();
    assert(
      directory.absolute.path.startsWith(Directory.systemTemp.absolute.path),
    );
    await directory.delete(recursive: true);
  });

  test(
    'version-4 upgrade retains counters and bookmarks without inventing completion',
    () async {
      expect(await db.getVersion(), 5);
      final counter = await service.getZikrCounter(77);
      expect(counter!.sessionCount, 12);
      expect(counter.lifetimeTotal, 99);
      final bookmark = await service.getLatestQuranProgress();
      expect(bookmark!.juzNumber, 14);
      expect(bookmark.rukuNumber, 22);
      expect(await RoutineService.todayRukus(), 0);
      expect(await service.completedRukuKeys(), isEmpty);
    },
  );
  test('bookmarks never add credit, including jumps to a later juz', () async {
    await service.saveQuranProgress(juzNumber: 30, rukuNumber: 1);
    expect(await RoutineService.todayRukus(), 0);
    expect(await service.completedRukuKeys(), isEmpty);
  });
  test(
    'completed reading deduplicates per day and does not fill skipped rukus',
    () async {
      await service.markRukuCompleted(juzNumber: 1, rukuNumber: 5);
      await service.markRukuCompleted(juzNumber: 1, rukuNumber: 5);
      expect(await RoutineService.todayRukus(), 1);
      expect(await service.completedRukuKeys(), {'1:5'});
      await service.markRukuCompleted(
        juzNumber: 2,
        rukuNumber: 1,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(await RoutineService.todayRukus(), 1);
      expect((await service.completedRukuKeys()).length, 2);
      await service.undoRukuCompletion(1, 5);
      expect(await RoutineService.todayRukus(), 0);
      expect(await service.completedRukuKeys(), {'2:1'});
    },
  );
  test('invalid completion cannot modify history or daily totals', () async {
    final before = (await service.getQuranHistory()).length;
    await expectLater(
      service.markRukuCompleted(juzNumber: 1, rukuNumber: 17),
      throwsArgumentError,
    );
    expect((await service.getQuranHistory()).length, before);
    expect(await RoutineService.todayRukus(), 0);
  });
  test('new backups restore completions and reading preferences', () async {
    await service.markRukuCompleted(juzNumber: 1, rukuNumber: 3);
    await ReadingPreferences.instance.save(
      arabicSize: 40,
      meaningSize: 22,
      showTransliteration: false,
      meaningLanguage: 'ur',
    );
    final content = await BackupService.exportJson();
    expect(jsonDecode(content)['version'], 2);
    await BackupService.resetProgress();
    await (await SharedPreferences.getInstance()).remove(
      ReadingPreferences.key,
    );
    await BackupService.restore(content);
    expect(await RoutineService.todayRukus(), 1);
    expect(ReadingPreferences.instance.arabicSize, 40);
    expect(ReadingPreferences.instance.meaningLanguage, 'ur');
    expect(ReadingPreferences.instance.showTransliteration, false);
    expect(await BackupService.exportCsv(), contains('quran_completed'));
  });
  test('old backups restore bookmarks with no reading credit', () async {
    await service.saveQuranProgress(juzNumber: 1, rukuNumber: 4);
    final backup = jsonDecode(await BackupService.exportJson());
    backup['version'] = 1;
    backup['tables'].remove('quran_completions');
    backup['preferences'].remove(ReadingPreferences.key);
    await service.markRukuCompleted(juzNumber: 1, rukuNumber: 5);
    await BackupService.restore(jsonEncode(backup));
    expect((await service.getLatestQuranProgress())!.rukuNumber, 4);
    expect(await RoutineService.todayRukus(), 0);
  });
  test(
    'malformed reading preferences or duplicate completions are rejected before restore',
    () async {
      await service.markRukuCompleted(juzNumber: 1, rukuNumber: 6);
      final backup = jsonDecode(await BackupService.exportJson());
      backup['preferences'][ReadingPreferences.key] = jsonEncode({
        'arabicSize': 900,
        'meaningSize': 16,
        'showTransliteration': true,
        'meaningLanguage': 'en',
      });
      await expectLater(
        BackupService.restore(jsonEncode(backup)),
        throwsFormatException,
      );
      expect(await RoutineService.todayRukus(), 1);
      backup['preferences'].remove(ReadingPreferences.key);
      backup['tables']['quran_completions'].add(
        backup['tables']['quran_completions'].first,
      );
      await expectLater(
        BackupService.restore(jsonEncode(backup)),
        throwsFormatException,
      );
      expect(await RoutineService.todayRukus(), 1);
    },
  );
  test(
    'legacy built-ins gain Urdu and transliteration without changing edited text',
    () async {
      final original = AdhkarService.defaults('morning').first;
      final legacy = original.toJson()
        ..remove('transliteration')
        ..remove('urduMeaning');
      final encoded = jsonEncode({
        'morning': [legacy],
        'evening': [],
      });
      final enriched = AdhkarService.decodeCollections(
        encoded,
      )['morning']!.single;
      expect(enriched.urduMeaning, isNotEmpty);
      expect(enriched.transliteration, isNotEmpty);
      legacy['translation'] = 'My own meaning';
      final edited = AdhkarService.decodeCollections(
        jsonEncode({
          'morning': [legacy],
          'evening': [],
        }),
      )['morning']!.single;
      expect(edited.translation, 'My own meaning');
      expect(edited.urduMeaning, isEmpty);
    },
  );

  testWidgets(
    'ruku sheet keeps bookmark, completion and undo as distinct actions',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      Future<void> settle() async {
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 40));
          await tester.runAsync(
            () async => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
        }
        await tester.pumpAndSettle();
      }

      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RukuSelectionPage(juzNumber: 1),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await settle();
      for (final (action, expected) in [
        ('save-quran-bookmark', 0),
        ('mark-quran-completed', 1),
        ('mark-quran-completed', 0),
      ]) {
        await tester.tap(find.byKey(const ValueKey('ruku-5')));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await tester.tap(find.byKey(ValueKey(action)));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await settle();
        final total = await tester.runAsync(RoutineService.todayRukus);
        expect(total, expected);
      }
      expect(await tester.runAsync(RoutineService.todayRukus), 0);
      expect(
        (await tester.runAsync(service.getLatestQuranProgress))!.rukuNumber,
        5,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
