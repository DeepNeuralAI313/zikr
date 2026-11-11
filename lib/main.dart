import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/services/quran_data_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/locale_service.dart';
import 'core/database_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/modern_home_page.dart';
import 'features/quran/juz_selection_page.dart';
import 'features/quran/ruku_selection_page.dart';
import 'features/zikr/zikr_list_page.dart';
import 'features/zikr/zikr_counter_page.dart';
import 'features/routine/routine_page.dart';
import 'features/adhkar/adhkar_page.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/appearance_page.dart';
import 'core/services/reading_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'generated/app_localizations.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureDatabaseFactory();
  
  // Initialize database
  try {
    print('=== DATABASE INITIALIZATION START ===');
    final db = DatabaseService();
    await db.database; // This will trigger database creation if needed
    print('Database initialized successfully');
    
    // Test database
    final counters = await db.getZikrCounters();
    print('Found ${counters.length} zikr counters:');
    for (var counter in counters) {
      print('  - ${counter.name}: session=${counter.sessionCount}, lifetime=${counter.lifetimeTotal}');
    }
    print('=== DATABASE INITIALIZATION END ===');
  } catch (e, stackTrace) {
    print('=== DATABASE INITIALIZATION ERROR ===');
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
  
  // Initialize Quran data service
  await QuranDataService.instance.loadData();
  
  // Initialize theme service
  await ThemeService.instance.loadTheme();
  
  // Initialize locale service
  await LocaleService.instance.loadLocale();
  await ReadingPreferences.instance.load();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

Future<void> _configureDatabaseFactory() async {
  if (kIsWeb) {
    // Web doesn't support sqflite - database operations will be skipped
    return;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      break;
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      // Mobile platforms use the default sqflite factory (already initialized)
      break;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeService.instance),
        ChangeNotifierProvider.value(value: LocaleService.instance),
      ],
      child: Consumer2<ThemeService, LocaleService>(
        builder: (context, themeService, localeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Dhikr - Quran Tracker',
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: themeService.themeMode,
            locale: localeService.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleService.supportedLocales,
            initialRoute: '/',
            routes: {
              '/': (context) => SplashScreen(),
              '/home': (context) => ModernHomePage(),
              '/routine': (context) => const RoutinePage(),
              '/adhkar': (context) => const AdhkarPage(),
              '/settings': (context) => const SettingsScreen(),
              '/appearance': (context) => const AppearancePage(),
              '/data-settings': (context) => const SettingsScreen(dataOnly: true),
              '/quran-flow': (context) => JuzSelectionPage(),
              '/ruku-selection': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                return RukuSelectionPage(juzNumber: args['juzNumber']);
              },
              '/zikr-flow': (context) => ZikrListPage(),
              '/zikr-counter': (context) {
                final zikr = ModalRoute.of(context)!.settings.arguments as ZikrItem;
                return ZikrCounterPage(zikr: zikr);
              },
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late List<Widget> _screens;
  
  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      label: 'Quran',
    ),
    NavigationItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Zikr',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _screens = [
      Container(), // Placeholder
      Container(), // Placeholder  
      Container(), // Placeholder
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: _navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _selectedIndex == index;
            
            return BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey(isSelected),
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
