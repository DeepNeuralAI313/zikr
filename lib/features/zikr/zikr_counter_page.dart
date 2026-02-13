import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../generated/app_localizations.dart';
import '../../core/theme.dart';
import '../../core/zikr_storage_service.dart';
import '../../core/utils/responsive_utils.dart';
import 'zikr_list_page.dart';

class ZikrCounterPage extends StatefulWidget {
  final ZikrItem zikr;
  
  const ZikrCounterPage({Key? key, required this.zikr}) : super(key: key);

  @override
  _ZikrCounterPageState createState() => _ZikrCounterPageState();
}

class _ZikrCounterPageState extends State<ZikrCounterPage>
    with TickerProviderStateMixin {
  late AnimationController _countAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  int currentCount = 0;
  int todayCount = 0;
  int lifetimeTotal = 0;
  final ZikrStorageService _storage = ZikrStorageService.instance;

  @override
  void initState() {
    super.initState();
    _loadZikrData();
    
    _countAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _countAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadZikrData() async {
    try {
      final count = await _storage.getZikrCount(widget.zikr.name);
      final todayCount = await _storage.getTodayZikrCount(widget.zikr.name);
      final lifetime = await _storage.getLifetimeTotal(widget.zikr.name);
      
      setState(() {
        currentCount = count;
        this.todayCount = todayCount;
        this.lifetimeTotal = lifetime;
      });
    } catch (e) {
      print('Error loading zikr data: $e');
    }
  }

  @override
  void dispose() {
    _countAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _incrementCount(int increment) async {
    HapticFeedback.mediumImpact();
    setState(() {
      currentCount += increment;
      todayCount += increment;
      lifetimeTotal += increment;
    });
    
    _countAnimationController.forward().then((_) {
      _countAnimationController.reverse();
    });

    // Save to storage
    try {
      final success = await _storage.incrementZikrCount(widget.zikr.name, increment);
      if (!success) {
        // Revert on failure
        setState(() {
          currentCount -= increment;
          todayCount -= increment;
          lifetimeTotal -= increment;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving count'),
            backgroundColor: accentPink,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating zikr count: $e');
      // Revert on error
      setState(() {
        currentCount -= increment;
        todayCount -= increment;
        lifetimeTotal -= increment;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving count: $e'),
          backgroundColor: accentPink,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCustomIncrementDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.customIncrementDialog,
          style: TextStyle(color: textColor),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: l10n.enterNumber,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: accentCyan),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(color: isDark ? accentGrey : accentGreyDark)),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              if (value > 0) {
                _incrementCount(value);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentCyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(l10n.add, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSession() async {
    if (currentCount == 0) return;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Session?', style: TextStyle(color: textColor)),
        content: Text(
          'This will save your current session ($currentCount) to history and reset the counter to 0.',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: isDark ? accentGrey : accentGreyDark)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      // Reset session in storage (this saves current session to history)
      final success = await _storage.resetZikrSession(widget.zikr.name);
      
      if (success) {
        setState(() {
          currentCount = 0;
        });
        
        // Reload data to get updated values
        await _loadZikrData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session reset successfully! History saved.'),
            backgroundColor: accentGreen,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting session'),
            backgroundColor: accentPink,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error resetting session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: accentPink,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Custom App Bar
                _buildAppBar(),
                
                // Main Content - Wrapped in Expanded and SingleChildScrollView
                Expanded(
                  child: SingleChildScrollView(
                    padding: ResponsiveUtils.getPagePadding(context),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 100,
                        maxWidth: ResponsiveUtils.isDesktop(context) ? 800 : double.infinity,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 30, desktop: 40)),
                            
                            // Zikr Text
                            _buildZikrText(),
                            
                            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 40, tablet: 50, desktop: 60)),
                            
                            // Counter Display
                            _buildCounterDisplay(),
                            
                            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 40, tablet: 50, desktop: 60)),
                            
                            // Increment Buttons
                            _buildIncrementButtons(),
                            
                            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 30, tablet: 40, desktop: 50)),
                            
                            // History
                            _buildHistory(),
                            
                            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 30, tablet: 40, desktop: 50)),
                            
                            // Line Chart
                            _buildLineChart(),
                            
                            SizedBox(height: 20), // Extra bottom padding
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

  Widget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final isLongText = widget.zikr.name.length > 40;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor, size: 24),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 12),
          Expanded(
            child: isLongText
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.zikr.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.zikr.name.length > 60)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Zikr Name',
                                  style: TextStyle(fontSize: 18),
                                ),
                                content: Text(
                                  widget.zikr.name,
                                  style: TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Read More',
                              style: TextStyle(
                                fontSize: 12,
                                color: accentCyan,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Text(
                    widget.zikr.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          SizedBox(width: 12),
          SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildZikrText() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: widget.zikr.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.zikr.gradient.colors[0].withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.zikr.arabic,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Amiri',
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            widget.zikr.meaning,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final counterSize = ResponsiveUtils.getCounterSize(context);
    final fontSize = ResponsiveUtils.getFontSize(context, mobile: 52, tablet: 60, desktop: 68);
    
    return Column(
      children: [
        // Main Counter - Current Session
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: () => _incrementCount(1),
                child: Container(
                  width: counterSize,
                  height: counterSize,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.zikr.gradient.colors[0],
                      width: ResponsiveUtils.isMobile(context) ? 4 : 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.zikr.gradient.colors[0].withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currentCount',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Current Session',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, mobile: 13, tablet: 15, desktop: 16),
                          color: isDark ? accentGrey : accentGreyDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        l10n.tapToCount,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, mobile: 11, tablet: 13, desktop: 14),
                          color: widget.zikr.gradient.colors[0],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 30, desktop: 36)),
        
        // Stats Row - Today's Total & Lifetime Total
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: accentCyan.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Today's Total",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, mobile: 12, tablet: 14, desktop: 15),
                        color: isDark ? accentGrey : accentGreyDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$todayCount',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, mobile: 28, tablet: 32, desktop: 36),
                        fontWeight: FontWeight.bold,
                        color: accentCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: accentGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'All-Time Total',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, mobile: 12, tablet: 14, desktop: 15),
                        color: isDark ? accentGrey : accentGreyDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$lifetimeTotal',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, mobile: 28, tablet: 32, desktop: 36),
                        fontWeight: FontWeight.bold,
                        color: accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        // Reset Button
        if (currentCount > 0)
          ElevatedButton.icon(
            onPressed: _resetSession,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Reset Session',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPink,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
          ),
      ],
    );
  }

  Widget _buildIncrementButtons() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIncrementButton('+100', accentPink, () => _incrementCount(100), screenWidth),
        _buildIncrementButton('+500', accentGreen, () => _incrementCount(500), screenWidth),
        _buildIncrementButton(l10n.customIncrement, accentCyan, _showCustomIncrementDialog, screenWidth),
      ],
    );
  }

  Widget _buildIncrementButton(String label, Color color, VoidCallback onPressed, double screenWidth) {
    // Responsive button size
    final buttonSize = (screenWidth * 0.22).clamp(70.0, 110.0);
    final fontSize = (screenWidth * 0.038).clamp(12.0, 18.0);
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _pulseController.forward(),
            onTapUp: (_) {
              _pulseController.reverse();
              onPressed();
            },
            onTapCancel: () => _pulseController.reverse(),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: widget.zikr.gradient.colors[0].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.historyTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.todayLabel,
                style: TextStyle(color: isDark ? accentGrey : accentGreyDark),
              ),
              Text(
                '+$todayCount',
                style: TextStyle(
                  color: widget.zikr.gradient.colors[0],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalLabel,
                style: TextStyle(color: isDark ? accentGrey : accentGreyDark),
              ),
              Text(
                '$currentCount',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    
    return FutureBuilder<Map<String, int>>(
      future: _storage.getZikrHistory(widget.zikr.name, days: 7),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        
        final history = snapshot.data!;
        
        // Convert to list and reverse so oldest is first
        final entries = history.entries.toList().reversed.toList();
        
        if (entries.isEmpty) {
          return SizedBox.shrink();
        }
        
        // Calculate max value for Y axis
        final maxCount = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
        final yMax = maxCount > 0 ? (maxCount * 1.2).ceilToDouble() : 10.0;
        
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: widget.zikr.gradient.colors[0].withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lastSevenDaysLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: yMax / 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: accentGrey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= entries.length) {
                              return Text('');
                            }
                            
                            // Parse date and show day
                            final dateStr = entries[index].key;
                            final date = DateTime.parse(dateStr);
                            final day = date.day.toString();
                            
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: accentGrey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: yMax / 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: accentGrey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: accentGrey.withOpacity(0.2),
                      ),
                    ),
                    minX: 0,
                    maxX: (entries.length - 1).toDouble(),
                    minY: 0,
                    maxY: yMax,
                    lineBarsData: [
                      LineChartBarData(
                        spots: entries.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.value.toDouble(),
                          );
                        }).toList(),
                        isCurved: true,
                        gradient: widget.zikr.gradient,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: widget.zikr.gradient.colors[0],
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              widget.zikr.gradient.colors[0].withOpacity(0.3),
                              widget.zikr.gradient.colors[0].withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => surfaceColor,
                        tooltipBorder: BorderSide(
                          color: widget.zikr.gradient.colors[0],
                          width: 1,
                        ),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            final dateStr = entries[index].key;
                            final date = DateTime.parse(dateStr);
                            final dateFormatted = '${date.day}/${date.month}';
                            
                            return LineTooltipItem(
                              '$dateFormatted\n${spot.y.toInt()} zikr',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}