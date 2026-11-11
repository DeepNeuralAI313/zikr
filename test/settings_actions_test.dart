import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zikr/core/database_service.dart';
import 'package:zikr/core/services/backup_service.dart';
import 'package:zikr/core/services/locale_service.dart';
import 'package:zikr/core/services/quran_data_service.dart';
import 'package:zikr/core/services/routine_service.dart';
import 'package:zikr/core/services/theme_service.dart';
import 'package:zikr/features/adhkar/adhkar_page.dart';
import 'package:zikr/features/home/modern_home_page.dart';
import 'package:zikr/features/routine/routine_page.dart';
import 'package:zikr/features/settings/settings_screen.dart';
import 'package:zikr/features/settings/appearance_page.dart';
import 'package:zikr/core/services/reading_preferences.dart';
import 'package:zikr/core/services/adhkar_service.dart';
import 'package:zikr/generated/app_localizations.dart';

class RecordingPicker extends FilePicker {
  final calls = <String>[];
  Uint8List? savedBytes;
  FilePickerResult? restoreFile;
  Completer<String?>? pending;
  bool fail = false;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    calls.add('save:${allowedExtensions!.single}');
    savedBytes = bytes;
    if (fail) {
      throw PlatformException(
        code: 'save_failed',
        message: 'Test save failure',
      );
    }
    return pending?.future;
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    calls.add('pick:${allowedExtensions!.single}');
    return restoreFile;
  }
}

class RouteRecorder extends NavigatorObserver {
  final opened = <String?>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    opened.add(route.settings.name);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporary;
  late Database db;
  late RecordingPicker picker;
  final shares = <MethodCall>[];
  final notifications = <MethodCall>[];
  final database = DatabaseService();
  late int counterId;
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    temporary = await Directory.systemTemp.createTemp('dhikr_settings_tests_');
    await databaseFactory.setDatabasesPath(temporary.path);
    db = await database.database;
    counterId = (await database.getZikrCounters()).first.id;
    await QuranDataService.instance.loadData();
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ThemeService.instance.loadTheme();
    await LocaleService.instance.loadLocale();
    await ReadingPreferences.instance.load();
    await db.delete('quran_progress');
    await db.delete('quran_completions');
    await db.delete('zikr_sessions');
    await db.update('zikr_counters', {
      'sessionCount': 0,
      'lifetimeTotal': 0,
      'lastUpdated': DateTime.now().toIso8601String(),
      'lastResetDate': dayKey(DateTime.now()),
    });
    picker = RecordingPicker();
    FilePicker.platform = picker;
    shares.clear();
    notifications.clear();
    PackageInfo.setMockInitialValues(
      appName: 'Dhikr - Quran Tracker',
      packageName: 'com.dhikrapp.qurantracker',
      version: '2.2.1',
      buildNumber: '12',
      buildSignature: 'test',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (call) async {
        shares.add(call);
        return 'selected-app';
      },
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => temporary.path,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('dhikr/widget'),
      (call) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (call) async => 'Asia/Kolkata',
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (call) async {
        notifications.add(call);
        return true;
      },
    );
  });
  tearDownAll(() async {
    await db.close();
    assert(
      temporary.absolute.path.startsWith(Directory.systemTemp.absolute.path),
    );
    await temporary.delete(recursive: true);
  });

  Widget app({Widget home = const SettingsScreen(), RouteRecorder? observer}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeService.instance),
          ChangeNotifierProvider.value(value: LocaleService.instance),
        ],
        child: AnimatedBuilder(
          animation: Listenable.merge([
            ThemeService.instance,
            LocaleService.instance,
          ]),
          builder: (context, _) => MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ),
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeService.instance.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: LocaleService.instance.locale,
            navigatorObservers: [if (observer != null) observer],
            home: home,
            routes: {
              '/routine': (_) => const RoutinePage(),
              '/settings': (_) => const SettingsScreen(),
              '/appearance': (_) => const AppearancePage(),
              '/data-settings': (_) => const SettingsScreen(dataOnly: true),
              '/adhkar': (_) => const AdhkarPage(),
              '/quran-flow': (_) => const Scaffold(),
              '/zikr-flow': (_) => const Scaffold(),
            },
          ),
        ),
      );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      final loading = find.byWidgetPredicate(
        (widget) =>
            widget is CircularProgressIndicator && widget.value == null ||
            widget is LinearProgressIndicator && widget.value == null,
      );
      if (i >= 1 && loading.evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder row) async {
    if (row.hitTestable().evaluate().isNotEmpty) return;
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    if ([
          'settings-backup',
          'settings-share',
          'settings-restore',
          'settings-csv',
          'settings-reset',
        ].contains(key) &&
        find.byKey(const ValueKey('settings-data')).evaluate().isNotEmpty) {
      await tap(tester, 'settings-data');
      await settle(tester);
      expect(find.text('Your data'), findsOneWidget);
    }
    if (key == 'settings-theme' &&
        find
            .byKey(const ValueKey('settings-appearance'))
            .evaluate()
            .isNotEmpty) {
      await tap(tester, 'settings-appearance');
      await settle(tester);
    }
    final row = find.byKey(ValueKey(key));
    await reveal(tester, row);
    await tester.runAsync(() async {
      await tester.tap(row);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
  }

  testWidgets('Settings groups open their corresponding pages', (tester) async {
    final observer = RouteRecorder();
    await tester.pumpWidget(app(observer: observer));
    await settle(tester);
    expect(find.byKey(const ValueKey('settings-backup')), findsNothing);
    await tap(tester, 'settings-appearance');
    await settle(tester);
    expect(find.byType(AppearancePage), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tap(tester, 'settings-routine');
    await settle(tester);
    expect(find.byType(RoutinePage), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tap(tester, 'settings-data');
    await settle(tester);
    expect(find.text('Your data'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-backup')), findsOneWidget);
    expect(
      observer.opened,
      containsAllInOrder(['/appearance', '/routine', '/data-settings']),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reading controls persist and apply to guided adhkar', (
    tester,
  ) async {
    await tester.pumpWidget(app(home: const AppearancePage()));
    await settle(tester);
    for (final key in ['arabic-size-slider', 'meaning-size-slider']) {
      final slider = find.byKey(ValueKey(key));
      await reveal(tester, slider);
      await tester.drag(slider, const Offset(70, 0));
      await settle(tester);
    }
    final reading = ReadingPreferences.instance;
    expect(reading.arabicSize, greaterThan(26));
    expect(reading.meaningSize, greaterThan(16));
    await tap(tester, 'show-transliteration');
    await settle(tester);
    expect(reading.showTransliteration, false);
    await tap(tester, 'meaning-language');
    await tester.pumpAndSettle();
    await tester.tap(find.text('اردو (Urdu)').last);
    await settle(tester);
    expect(reading.meaningLanguage, 'ur');
    final saved = (await SharedPreferences.getInstance()).getString(
      ReadingPreferences.key,
    );
    expect(ReadingPreferences.decode(saved!)['showTransliteration'], false);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await reading.load();
    await tester.pumpWidget(app(home: const AdhkarPage()));
    await settle(tester);
    final first = adhkarEntries.first;
    final meaning = find.text(first.urduMeaning);
    expect(meaning, findsOneWidget);
    expect(tester.widget<Text>(meaning).style!.fontSize, reading.meaningSize);
    expect(
      tester.widget<EditableText>(find.text(first.arabic)).style.fontSize,
      reading.arabicSize,
    );
    expect(find.text(first.transliteration), findsNothing);
    await tester.runAsync(() => reading.save(showTransliteration: true));
    await settle(tester);
    expect(find.text(first.transliteration), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'ar', 'ur']) {
    testWidgets('Appearance fits a narrow $language screen', (tester) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await LocaleService.instance.setLocale(Locale(language));
      await tester.pumpWidget(app(home: const AppearancePage()));
      await settle(tester);
      await reveal(tester, find.byKey(const ValueKey('meaning-language')));
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'CSV, backup, restore and share each call only their own operation',
    (tester) async {
      await tester.pumpWidget(app());
      await settle(tester);
      await tap(tester, 'settings-csv');
      await settle(tester);
      expect(picker.calls, ['save:csv']);
      expect(
        utf8.decode(picker.savedBytes!),
        startsWith('type,name_or_location,'),
      );
      expect(shares, isEmpty);
      await tap(tester, 'settings-backup');
      await settle(tester);
      expect(picker.calls, ['save:csv', 'save:json']);
      expect(
        jsonDecode(utf8.decode(picker.savedBytes!))['app'],
        'dhikr-quran-tracker',
      );
      await tap(tester, 'settings-restore');
      await settle(tester);
      expect(picker.calls.last, 'pick:json');
      expect(shares, isEmpty);
      await tap(tester, 'settings-share');
      await settle(tester);
      expect(picker.calls.length, 3);
      expect(shares.length, 1);
      expect(shares.single.method, 'share');
      expect(shares.single.arguments['title'], 'Share backup');
      final shared = File(
        (shares.single.arguments['paths'] as List).single as String,
      );
      expect(
        jsonDecode((await tester.runAsync(shared.readAsString))!)['app'],
        'dhikr-quran-tracker',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'busy action keeps row positions fixed and blocks a second action',
    (tester) async {
      await tester.pumpWidget(app());
      await settle(tester);
      await tap(tester, 'settings-data');
      await settle(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('settings-csv')));
      await tester.pumpAndSettle();
      final before = tester.getTopLeft(
        find.byKey(const ValueKey('settings-csv')),
      );
      picker.pending = Completer<String?>();
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('settings-csv')));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('settings-csv'))),
        before,
      );
      expect(find.byKey(const ValueKey('settings-busy')), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('settings-reset')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(shares, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      expect(picker.calls, ['save:csv']);
      picker.pending!.complete(null);
      await settle(tester);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('settings-csv'))),
        before,
      );
      await tap(tester, 'settings-share');
      await settle(tester);
      expect(shares.length, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'native picker failure leaves rows stable and other buttons work',
    (tester) async {
      await tester.pumpWidget(app());
      await settle(tester);
      await tap(tester, 'settings-data');
      await settle(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('settings-csv')));
      await tester.pumpAndSettle();
      final before = tester.getTopLeft(
        find.byKey(const ValueKey('settings-csv')),
      );
      picker.fail = true;
      await tap(tester, 'settings-csv');
      await settle(tester);
      expect(find.textContaining('Test save failure'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('settings-csv'))),
        before,
      );
      picker.fail = false;
      await tap(tester, 'settings-restore');
      await settle(tester);
      expect(picker.calls, ['save:csv', 'pick:json']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'routine opens once, saves the chosen goals, and returns to Settings',
    (tester) async {
      final observer = RouteRecorder();
      await tester.pumpWidget(app(observer: observer));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('settings-routine')));
      await tester.tap(
        find.byKey(const ValueKey('settings-routine')),
        warnIfMissed: false,
      );
      await settle(tester);
      expect(observer.opened.where((name) => name == '/routine').length, 1);
      await tester.enterText(find.byType(TextField).at(0), '345');
      await tester.enterText(find.byType(TextField).at(1), '5');
      await tester.ensureVisible(find.text('Save routine'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Save routine'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      expect((await RoutineService.settings())['dhikrGoal'], 345);
      expect((await RoutineService.settings())['rukuGoal'], 5);
      await tester.pageBack();
      await settle(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'theme changes persist and information rows open the correct dialog',
    (tester) async {
      await tester.pumpWidget(app());
      await settle(tester);
      await tap(tester, 'settings-theme');
      await settle(tester);
      expect(
        (await SharedPreferences.getInstance()).getBool('theme_mode'),
        true,
      );
      expect(
        Theme.of(tester.element(find.byType(AppearancePage))).brightness,
        Brightness.dark,
      );
      await tester.pageBack();
      await settle(tester);
      for (final item in [
        ('settings-widget', 'Android home-screen widget'),
        ('settings-privacy', 'Your data stays on your device'),
      ]) {
        await tap(tester, item.$1);
        await settle(tester);
        final dialog = find.byType(AlertDialog);
        expect(
          find.descendant(of: dialog, matching: find.text(item.$2)),
          findsOneWidget,
        );
        await tester.tap(find.text('Close'));
        await settle(tester);
      }
      expect(find.byKey(const ValueKey('settings-version')), findsNothing);
      expect(find.text('App version'), findsNothing);
      expect(find.text('2.2.1 (12)'), findsNothing);
    },
  );

  testWidgets(
    'reset cancel preserves data and reset confirm clears only progress',
    (tester) async {
      await tester.runAsync(() => database.incrementZikrCount(counterId, 25));
      await tester.pumpWidget(app());
      await settle(tester);
      await tap(tester, 'settings-reset');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(
        await tester.runAsync(() => database.getTodayZikrTotal(counterId)),
        25,
      );
      await tap(tester, 'settings-reset');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() async {
        await tester.tap(find.text('Continue'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await settle(tester);
      expect(
        await tester.runAsync(() => database.getTodayZikrTotal(counterId)),
        0,
      );
      expect(picker.calls, isEmpty);
      expect(shares, isEmpty);
    },
  );

  testWidgets(
    'restore uses the selected JSON and respects cancel and confirm',
    (tester) async {
      await tester.runAsync(() => database.incrementZikrCount(counterId, 7));
      final backup = await tester.runAsync(BackupService.exportJson);
      await tester.runAsync(() => database.incrementZikrCount(counterId, 5));
      final bytes = Uint8List.fromList(utf8.encode(backup!));
      picker.restoreFile = FilePickerResult([
        PlatformFile(name: 'progress.json', size: bytes.length, bytes: bytes),
      ]);
      await tester.pumpWidget(app());
      await settle(tester);
      await tap(tester, 'settings-restore');
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Restore backup'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(
        await tester.runAsync(() => database.getTodayZikrTotal(counterId)),
        12,
      );
      await tap(tester, 'settings-restore');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() async {
        await tester.tap(find.text('Continue'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await settle(tester);
      expect(
        await tester.runAsync(() => database.getTodayZikrTotal(counterId)),
        7,
      );
      expect(picker.calls, ['pick:json', 'pick:json']);
      expect(shares, isEmpty);
    },
  );

  testWidgets(
    'invalid restore leaves progress intact and releases the buttons',
    (tester) async {
      await tester.runAsync(() => database.incrementZikrCount(counterId, 9));
      picker.restoreFile = FilePickerResult([
        PlatformFile(
          name: 'bad.json',
          size: 2,
          bytes: Uint8List.fromList(utf8.encode('{}')),
        ),
      ]);
      await tester.pumpWidget(app());
      await settle(tester);
      await tap(tester, 'settings-restore');
      await settle(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        await tester.runAsync(() => database.getTodayZikrTotal(counterId)),
        9,
      );
      await tap(tester, 'settings-csv');
      await settle(tester);
      expect(picker.calls, ['pick:json', 'save:csv']);
    },
  );

  testWidgets('rapid home taps do not stack different screens', (tester) async {
    final observer = RouteRecorder();
    await tester.runAsync(() async {
      await tester.pumpWidget(app(home: ModernHomePage(), observer: observer));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    // The home screen issues several SQLite transactions. Flush both Flutter's
    // fake clock and the FFI isolate between them before settling animations.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
    }
    await settle(tester);
    await tester.ensureVisible(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.tap(
      find.text('Morning & evening adhkar'),
      warnIfMissed: false,
    );
    await settle(tester);
    expect(observer.opened.where((name) => name == '/settings').length, 1);
    expect(observer.opened.where((name) => name == '/adhkar'), isEmpty);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'planner and each reminder picker update and save the correct fields',
    (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(app(home: const RoutinePage()));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await settle(tester);
      await tester.ensureVisible(find.text('Finish date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish date'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Use this daily target'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use this daily target'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Daily reminders'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Daily reminders'));
      await tester.pumpAndSettle();
      for (final item in [
        ('Dhikr reminder', '07', '15'),
        ('Quran reminder', '21', '45'),
      ]) {
        await tester.ensureVisible(find.text(item.$1));
        await tester.pumpAndSettle();
        await tester.tap(find.text(item.$1));
        await tester.pumpAndSettle();
        final dialog = find.byType(TimePickerDialog);
        expect(dialog, findsOneWidget);
        await tester.tap(find.byIcon(Icons.keyboard_outlined));
        await tester.pumpAndSettle();
        final inputs = find.descendant(
          of: dialog,
          matching: find.byType(TextField),
        );
        await tester.enterText(inputs.at(0), item.$2);
        await tester.enterText(inputs.at(1), item.$3);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.text('Save routine'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Save routine'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await settle(tester);
      final config = await RoutineService.settings();
      expect(config['dhikrMinute'], 435);
      expect(config['quranMinute'], 1305);
      expect(config['reminders'], true);
      final days = RoutineService.daysRemaining(
        DateTime.parse(config['finishDate']),
        DateTime.now(),
      );
      expect(config['rukuGoal'], (RoutineService.totalRukus / days).ceil());
      expect(
        notifications.where((call) => call.method == 'zonedSchedule').length,
        2,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
