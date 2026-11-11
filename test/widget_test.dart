import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zikr/core/services/theme_service.dart';
import 'package:zikr/main.dart';

void main() {
  testWidgets(
    'App starts with the default light theme and restores dark theme',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await ThemeService.instance.loadTheme();
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light,
      );
      await ThemeService.instance.setTheme(ThemeMode.dark);
      await tester.pump();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
      await ThemeService.instance.loadTheme();
      expect(ThemeService.instance.themeMode, ThemeMode.dark);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
