import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zikr/core/services/adhkar_service.dart';
import 'package:zikr/core/services/routine_service.dart';
import 'package:zikr/features/adhkar/adhkar_page.dart';
import 'package:zikr/generated/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  Widget app({String language = 'en'}) => MaterialApp(
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const AdhkarPage(),
  );

  Future<void> lane(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> add(
    WidgetTester tester,
    String name, {
    bool both = false,
    int target = 4,
  }) async {
    await tester.tap(find.byKey(const ValueKey('add-guided-dhikr')));
    await tester.pumpAndSettle();
    if (both) {
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Morning and evening').last);
      await tester.pumpAndSettle();
    }
    await tester.enterText(find.byKey(const ValueKey('guided-title')), name);
    final targetField = find.byKey(const ValueKey('guided-target'));
    await tester.ensureVisible(targetField);
    await tester.pumpAndSettle();
    await tester.enterText(targetField, '$target');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
  }

  test(
    'defaults have separate time-specific supplications and stable legacy IDs',
    () async {
      final collections = await AdhkarService.load();
      expect(collections['morning']!.map((e) => e.id), [
        '0',
        '1',
        '2',
        '3',
        'morning_dua',
      ]);
      expect(collections['evening']!.last.id, 'evening_dua');
      expect(
        collections['morning']!.last.arabic,
        isNot(collections['evening']!.last.arabic),
      );
      expect(collections['morning']!.last.arabic, contains('أَصْبَحْنَا'));
      expect(collections['evening']!.last.arabic, contains('أَمْسَيْنَا'));
    },
  );
  test(
    'malformed targets and duplicate IDs cannot replace saved collections',
    () async {
      final collections = await AdhkarService.load();
      await AdhkarService.save(collections);
      collections['morning']!.add(
        const AdhkarEntry('Invalid', '', '', '', 0, id: 'invalid'),
      );
      await expectLater(AdhkarService.save(collections), throwsFormatException);
      expect((await AdhkarService.load())['morning']!.length, 5);
    },
  );

  testWidgets('add to Morning only persists without changing Evening', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await lane(tester, 'Morning');
    await add(tester, 'My morning dhikr');
    final saved = await AdhkarService.load();
    expect(saved['morning']!.last.title, 'My morning dhikr');
    expect(
      saved['evening']!.any((e) => e.title == 'My morning dhikr'),
      isFalse,
    );
    final id = saved['morning']!.last.id;
    final counter = find.byKey(ValueKey('count-morning-$id'));
    await reveal(tester, counter);
    await tester.tap(counter);
    await tester.pumpAndSettle();
    await tester.tap(counter);
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(
      jsonDecode(
        prefs.getString(AdhkarService.countsKey)!,
      )['${dayKey(DateTime.now())}:morning:$id'],
      2,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await lane(tester, 'Morning');
    await reveal(tester, find.byKey(ValueKey('count-morning-$id')));
    expect(find.text('Tap to count · 2 / 4'), findsOneWidget);
    await lane(tester, 'Evening');
    expect(find.text('My morning dhikr'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add to both, edit one list and delete one list independently', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await lane(tester, 'Morning');
    await add(tester, 'Shared custom dhikr', both: true);
    final initial = await AdhkarService.load();
    final id = initial['morning']!.last.id;
    expect(initial['evening']!.last.id, id);
    final countKey = ValueKey('count-morning-$id');
    await reveal(tester, find.byKey(countKey));
    await tester.tap(find.byKey(countKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('edit-morning-$id')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('guided-title')),
      'Edited morning dhikr',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('guided-target')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('guided-target')), '8');
    await tester.tap(find.text('Save dhikr'));
    await tester.pumpAndSettle();
    final edited = await AdhkarService.load();
    expect(edited['morning']!.last.title, 'Edited morning dhikr');
    expect(edited['evening']!.last.title, 'Shared custom dhikr');
    expect(edited['morning']!.last.id, id);
    await reveal(tester, find.byKey(countKey));
    expect(find.text('Tap to count · 1 / 8'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('delete-morning-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((await AdhkarService.load())['morning']!.last.id, id);
    await tester.tap(find.byKey(ValueKey('delete-morning-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete dhikr'));
    await tester.pumpAndSettle();
    final deleted = await AdhkarService.load();
    expect(deleted['morning']!.any((e) => e.id == id), false);
    expect(deleted['evening']!.any((e) => e.id == id), true);
    await lane(tester, 'Evening');
    await reveal(tester, find.byKey(ValueKey('count-evening-$id')));
    expect(find.text('Tap to count · 0 / 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'deleting a default entry preserves other entries and legacy counts',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AdhkarService.countsKey,
        jsonEncode({
          '${dayKey(DateTime.now())}:morning:0': 1,
          '${dayKey(DateTime.now())}:morning:1': 2,
        }),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await lane(tester, 'Morning');
      await tester.tap(find.byKey(const ValueKey('delete-morning-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete dhikr'));
      await tester.pumpAndSettle();
      expect((await AdhkarService.load())['morning']!.first.id, '1');
      expect(find.text('Tap to count · 2 / 3'), findsOneWidget);
      await lane(tester, 'Evening');
      expect((await AdhkarService.load())['evening']!.first.id, '0');
      expect(find.text('Tap to count · 0 / 3'), findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'empty collections stay empty after reload and still allow adding',
    (tester) async {
      await AdhkarService.save({'morning': [], 'evening': []});
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(
        find.text('This list is empty. Add your first dhikr above.'),
        findsOneWidget,
      );
      await add(tester, 'First dhikr');
      expect((await AdhkarService.load()).values.expand((v) => v).length, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'invalid form values stay in the editor without changing storage',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add-guided-dhikr')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('guided-target')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('guided-target')), '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Enter whole numbers from 1 to 1,000,000.'),
        findsOneWidget,
      );
      expect(
        (await SharedPreferences.getInstance()).getString(
          AdhkarService.collectionsKey,
        ),
        isNull,
      );
    },
  );

  for (final language in ['ar', 'ur']) {
    testWidgets('$language guided list and editor fit a narrow screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(language: language));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final l = AppLocalizations.of(tester.element(find.byType(AdhkarPage)))!;
      await tester.tap(find.byKey(const ValueKey('add-guided-dhikr')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.byKey(const ValueKey('guided-title')),
        'ذکر خاص',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('guided-target')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, l.add));
      await tester.pumpAndSettle();
      expect(
        (await AdhkarService.load()).values
            .expand((v) => v)
            .any((e) => e.title == 'ذکر خاص'),
        true,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
