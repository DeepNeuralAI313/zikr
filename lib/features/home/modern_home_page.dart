import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../generated/app_localizations.dart';
import '../../core/theme.dart';
import '../../core/database_service.dart';
import '../../core/models.dart';
import '../../core/zikr_storage_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/locale_service.dart';
import '../../core/services/app_update_service.dart';
import '../../core/utils/responsive_utils.dart';
import '../routine/daily_progress_card.dart';
import '../../core/services/routine_service.dart';
import '../../core/services/reminder_service.dart';

class ModernHomePage extends StatefulWidget {
  @override
  _ModernHomePageState createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  // State variables for real data
  QuranProgress? lastQuranProgress;
  Map<String, int> zikrCounts = {};
  int todayTotalZikr = 0;
  int totalZikr = 0;
  bool isLoading = true;
  bool _openingRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocaleService.instance.addListener(_localeChanged);
    RoutineService.widgetChannel.setMethodCallHandler((call) async {
      if (call.method == 'openCounters' && mounted) _onCardTap('/zikr-flow');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final route = await RoutineService.widgetChannel.invokeMethod<String>('launchRoute');
        if (mounted && route == '/zikr-flow') _onCardTap(route!);
      } on PlatformException catch (_) {
      } on MissingPluginException catch (_) {}
    });
    _refreshReminders();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _loadData();
    
    // Check for app updates after page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService().checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocaleService.instance.removeListener(_localeChanged);
    RoutineService.widgetChannel.setMethodCallHandler(null);
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _refreshReminders() async {
    try {
      await ReminderService.instance.schedule(await RoutineService.settings());
    } catch (e) { debugPrint('Reminder refresh failed: $e'); }
  }

  void _localeChanged() {
    _refreshReminders();
    RoutineService.progressChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) { _loadData(); _refreshReminders(); }
  }

  Future<void> _loadData() async {
    try {
      final storage = ZikrStorageService.instance;
      
      // Load Zikr data from storage (works on all platforms)
      final allZikrCounts = await storage.getAllZikrCounts();
      final todayTotal = await storage.getTodayTotalZikrCount();
      final lifetimeTotals = await storage.getAllLifetimeTotals();
      final totalCount = lifetimeTotals.values.fold<int>(0, (sum, count) => sum + count);
      
      // Load Quran progress (only on non-web platforms)
      QuranProgress? quranProgress;
      try {
        final database = DatabaseService();
        quranProgress = await database.getLatestQuranProgress();
      } catch (e) {
        print('Quran progress not available on this platform: $e');
      }
      
      if (!mounted) return;
      setState(() {
        lastQuranProgress = quranProgress;
        zikrCounts = allZikrCounts;
        todayTotalZikr = todayTotal;
        totalZikr = totalCount;
        isLoading = false;
      });
      RoutineService.changes.value++;
      await RoutineService.updateWidget();
    } catch (e) {
      print('Error loading data: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onCardTap(String route) async {
    if (_openingRoute || !mounted) return;
    _openingRoute = true;
    HapticFeedback.lightImpact();
    try {
      _scaleController.reverse();
      await Navigator.pushNamed(context, route);
      if (mounted) await _loadData();
    } finally {
      _openingRoute = false;
    }
  }

  String _getQuranStatusText() {
    final l10n = AppLocalizations.of(context)!;
    if (lastQuranProgress == null) {
      return l10n.startReading;
    }
    return l10n.lastProgress(lastQuranProgress!.displayLocation);
  }

  String _getZikrStatusText() {
    final l10n = AppLocalizations.of(context)!;
    if (zikrCounts.isEmpty) {
      return l10n.startZikr;
    }
    
    // Find the most recent Zikr with highest count
    String? mostActiveZikr;
    int highestCount = 0;
    
    for (var entry in zikrCounts.entries) {
      if (entry.value > highestCount) {
        highestCount = entry.value;
        mostActiveZikr = entry.key;
      }
    }
    
    if (mostActiveZikr != null && highestCount > 0) {
      // Truncate long zikr names to prevent overflow
      String displayName = mostActiveZikr;
      if (displayName.length > 30) {
        displayName = displayName.substring(0, 30) + '...';
      }
      return "$displayName – $highestCount";
    }
    
    return l10n.startFirstZikr;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTabletOrDesktop = ResponsiveUtils.isDesktop(context);
            final maxWidth = isTabletOrDesktop ? 800.0 : double.infinity;
            
            return Column(
              children: [
                // Custom App Bar
                _buildAppBar(),
                
                // Main Content
                Expanded(
                  child: isLoading 
                    ? _buildLoadingState()
                    : Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            padding: ResponsiveUtils.getPagePadding(context),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 30, desktop: 40)),
                                
                                // Quran Card
                                const DailyProgressCard(),
                                const SizedBox(height: 16),
                                Wrap(spacing: 12, runSpacing: 8, children: [
                                  ActionChip(avatar: const Icon(Icons.auto_stories_outlined),
                                    label: Text(AppLocalizations.of(context)!.guidedAdhkar),
                                    onPressed: () => _onCardTap('/adhkar')),
                                  ActionChip(avatar: const Icon(Icons.settings_outlined),
                                    label: Text(AppLocalizations.of(context)!.settings),
                                    onPressed: () => _onCardTap('/settings')),
                                ]),
                                const SizedBox(height: 20),
                                _buildQuranCard(),
                                
                                SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 25, tablet: 35, desktop: 45)),
                                
                                // Zikr Card
                                _buildZikrCard(),
                                
                                SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 35, tablet: 45, desktop: 55)),
                                
                                // Stats or additional info
                                _buildStatsRow(),
                                
                                SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 30, desktop: 40)),
                              ],
                            ),
                          ),
                        ),
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentCyan),
          ),
          SizedBox(height: 16),
          Text(
            l10n.loadingProgress,
            style: TextStyle(
              fontSize: 16,
              color: accentGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final iconSize = screenWidth * 0.065; // ~24-28px on most devices
    final logoFontSize = screenWidth * 0.095; // ~34-42px on most devices
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Theme Toggle Button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<ThemeService>().toggleTheme();
            },
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? accentYellow : accentPurple,
              size: iconSize,
            ),
            tooltip: isDark ? AppLocalizations.of(context)!.lightMode : AppLocalizations.of(context)!.darkMode,
          ),
          
          // Logo
          Expanded(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.005),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppGradients.logoGradient.createShader(bounds),
                    child: Text(
                      'ذِكْر', // Arabic for "Zikr"
                      style: TextStyle(
                        fontSize: logoFontSize.clamp(28.0, 48.0), // Min 28, Max 48
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Language Selector (placeholder for now)
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showLanguageDialog();
            },
            icon: Icon(
              Icons.language,
              color: isDark ? accentCyan : accentGreen,
              size: iconSize,
            ),
            tooltip: AppLocalizations.of(context)!.changeLanguage,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final localeService = context.read<LocaleService>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.changeLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: Text(AppLocalizations.of(context)!.english),
              trailing: localeService.locale.languageCode == 'en' 
                  ? Icon(Icons.check, color: accentGreen) 
                  : null,
              onTap: () {
                localeService.setLocale(Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text('🇸🇦', style: TextStyle(fontSize: 24)),
              title: Text(AppLocalizations.of(context)!.arabic),
              trailing: localeService.locale.languageCode == 'ar' 
                  ? Icon(Icons.check, color: accentGreen) 
                  : null,
              onTap: () {
                localeService.setLocale(Locale('ar'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text('🇵🇰', style: TextStyle(fontSize: 24)),
              title: Text(AppLocalizations.of(context)!.urdu),
              trailing: localeService.locale.languageCode == 'ur' 
                  ? Icon(Icons.check, color: accentGreen) 
                  : null,
              onTap: () {
                localeService.setLocale(Locale('ur'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranCard() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final iconSize = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.065; // ~24-28px
    final subtitleFontSize = screenWidth * 0.038; // ~14-16px
    final buttonFontSize = screenWidth * 0.035; // ~12-14px
    final padding = screenWidth * 0.05;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _onCardTap('/quran-flow'),
            onTapCancel: () => _scaleController.reverse(),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.quranGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: accentGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                '📖',
                                style: TextStyle(fontSize: iconSize),
                              ),
                              SizedBox(width: screenWidth * 0.025),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.quran,
                                  style: TextStyle(
                                    fontSize: titleFontSize.clamp(22.0, 32.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          Text(
                            _getQuranStatusText(),
                            style: TextStyle(
                              fontSize: subtitleFontSize.clamp(13.0, 18.0),
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                lastQuranProgress != null ? AppLocalizations.of(context)!.continueReading : AppLocalizations.of(context)!.startReading,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: buttonFontSize.clamp(11.0, 16.0),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildZikrCard() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final iconSize = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.065; // ~24-28px
    final subtitleFontSize = screenWidth * 0.038; // ~14-16px
    final buttonFontSize = screenWidth * 0.035; // ~12-14px
    final padding = screenWidth * 0.05;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _onCardTap('/zikr-flow'),
            onTapCancel: () => _scaleController.reverse(),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.zikrGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: accentPink.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                '🕌',
                                style: TextStyle(fontSize: iconSize),
                              ),
                              SizedBox(width: screenWidth * 0.025),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.zikr,
                                  style: TextStyle(
                                    fontSize: titleFontSize.clamp(22.0, 32.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          Text(
                            _getZikrStatusText(),
                            style: TextStyle(
                              fontSize: subtitleFontSize.clamp(13.0, 18.0),
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                todayTotalZikr > 0 ? AppLocalizations.of(context)!.continueZikr : AppLocalizations.of(context)!.startZikr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: buttonFontSize.clamp(11.0, 16.0),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final valueFontSize = screenWidth * 0.035; // ~12-15px
    final titleFontSize = screenWidth * 0.028; // ~10-12px
    final verticalPadding = screenHeight * 0.015;
    final horizontalPadding = screenWidth * 0.02;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          l10n.todayZikr, 
          '${todayTotalZikr} ${l10n.total}', 
          accentYellow,
          valueFontSize,
          titleFontSize,
          verticalPadding,
          horizontalPadding,
        ),
        _buildStatItem(
          l10n.totalZikr, 
          '${totalZikr} ${l10n.total}', 
          accentCyan,
          valueFontSize,
          titleFontSize,
          verticalPadding,
          horizontalPadding,
        ),
        _buildStatItem(
          l10n.activeZikrs, 
          '${zikrCounts.values.where((count) => count > 0).length}/${ZikrStorageService.predefinedZikr.length}', 
          accentPurple,
          valueFontSize,
          titleFontSize,
          verticalPadding,
          horizontalPadding,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String title, 
    String value, 
    Color color,
    double valueFontSize,
    double titleFontSize,
    double verticalPadding,
    double horizontalPadding,
  ) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding.clamp(6.0, 12.0),
          vertical: verticalPadding.clamp(10.0, 16.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize.clamp(11.0, 16.0),
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize.clamp(9.0, 13.0),
                color: accentGrey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
