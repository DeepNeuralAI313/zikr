import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/app_localizations.dart';
import '../../core/theme.dart';
import '../../core/zikr_storage_service.dart';

class ZikrListPage extends StatefulWidget {
  @override
  _ZikrListPageState createState() => _ZikrListPageState();
}

class _ZikrListPageState extends State<ZikrListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ZikrStorageService _storage = ZikrStorageService.instance;
  List<ZikrItem> zikrItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('ZikrListPage: initState called');
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600), // Reduced from 800ms
      vsync: this,
    );
    _loadZikrData();
  }

  Future<void> _loadZikrData() async {
    print('ZikrListPage: _loadZikrData started');
    try {
      // Get all current counts
      final allCounts = await _storage.getAllZikrCounts();
      
      // Get all zikrs (predefined + custom)
      final allZikrs = await _storage.getAllZikrs();
      
      List<ZikrItem> items = [];
      
      // Create ZikrItem for each zikr
      for (int i = 0; i < allZikrs.length; i++) {
        final zikr = allZikrs[i];
        final count = allCounts[zikr['name']] ?? 0;
        
        // Use rotating colors
        final gradient = _getGradientForIndex(i);
        
        items.add(ZikrItem(
          name: zikr['name']!,
          arabic: zikr['arabic']!,
          meaning: zikr['meaning']!,
          gradient: gradient,
          count: count,
        ));
      }

      setState(() {
        zikrItems = items;
        isLoading = false;
      });
      
      print('ZikrListPage: Loaded ${items.length} zikr items successfully');
      _animationController.forward();
    } catch (e) {
      print('Error loading zikr data: $e');
      // Create fallback data even if storage fails
      List<ZikrItem> fallbackItems = [];
      
      for (int i = 0; i < ZikrStorageService.predefinedZikr.length; i++) {
        final zikr = ZikrStorageService.predefinedZikr[i];
        final gradient = _getGradientForIndex(i);
        
        fallbackItems.add(ZikrItem(
          name: zikr['name']!,
          arabic: zikr['arabic']!,
          meaning: zikr['meaning']!,
          gradient: gradient,
          count: 0,
        ));
      }
      
      setState(() {
        zikrItems = fallbackItems;
        isLoading = false;
      });
      
      print('ZikrListPage: Using fallback data with ${fallbackItems.length} items');
      _animationController.forward();
    }
  }
  
  LinearGradient _getGradientForIndex(int index) {
    switch (index % 5) {
      case 0:
        return LinearGradient(colors: [accentYellow, accentYellow.withOpacity(0.7)]);
      case 1:
        return LinearGradient(colors: [accentGreen, accentGreen.withOpacity(0.7)]);
      case 2:
        return LinearGradient(colors: [accentPink, accentPink.withOpacity(0.7)]);
      case 3:
        return LinearGradient(colors: [accentCyan, accentCyan.withOpacity(0.7)]);
      case 4:
        return LinearGradient(colors: [accentPurple, accentPurple.withOpacity(0.7)]);
      default:
        return LinearGradient(colors: [accentYellow, accentYellow.withOpacity(0.7)]);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onZikrSelected(ZikrItem zikr) async {
    HapticFeedback.mediumImpact();
    // Wait for the counter page to return
    await Navigator.pushNamed(
      context,
      '/zikr-counter',
      arguments: zikr,
    );
    // Reload data when user comes back
    print('ZikrListPage: User returned from counter, reloading data...');
    _loadZikrData();
  }

  void _showAddZikrDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    
    final nameController = TextEditingController();
    final arabicController = TextEditingController();
    final meaningController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.addCustomZikr,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nameRequired,
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: l10n.nameLabel,
                  labelStyle: TextStyle(color: isDark ? accentGrey : accentGreyDark),
                  hintText: 'e.g., Durood Sharif',
                  hintStyle: TextStyle(color: isDark ? accentGrey.withOpacity(0.5) : accentGreyDark.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentCyan.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentCyan),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: arabicController,
                style: TextStyle(color: textColor, fontFamily: 'Amiri'),
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: l10n.arabicText,
                  labelStyle: TextStyle(color: isDark ? accentGrey : accentGreyDark),
                  hintText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
                  hintStyle: TextStyle(color: isDark ? accentGrey.withOpacity(0.5) : accentGreyDark.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentCyan.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentCyan),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: meaningController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: l10n.meaning,
                  labelStyle: TextStyle(color: isDark ? accentGrey : accentGreyDark),
                  hintText: 'O Allah, send blessings upon Muhammad',
                  hintStyle: TextStyle(color: isDark ? accentGrey.withOpacity(0.5) : accentGreyDark.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentCyan.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentCyan),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(color: isDark ? accentGrey : accentGreyDark)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final arabic = arabicController.text.trim();
              final meaning = meaningController.text.trim();
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.nameIsRequired),
                    backgroundColor: accentPink,
                  ),
                );
                return;
              }
              
              final success = await _storage.addCustomZikr(
                name: name,
                arabic: arabic.isEmpty ? name : arabic,
                meaning: meaning.isEmpty ? l10n.customZikr : meaning,
              );
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.zikrAddedSuccessfully),
                    backgroundColor: accentGreen,
                  ),
                );
                _loadZikrData(); // Reload the list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.zikrAlreadyExists),
                    backgroundColor: accentPink,
                  ),
                );
              }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(l10n.selectZikr),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddZikrDialog,
        backgroundColor: accentCyan,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.addZikr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              l10n.chooseYourZikr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.selectTheZikr,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? accentGrey : accentGreyDark,
              ),
            ),
            SizedBox(height: 32),
            
            // Loading or List of Zikr items
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(accentCyan),
                      ),
                    )
                  : Builder(
                      builder: (context) {
                        print('ZikrListPage: Building list with ${zikrItems.length} items');
                        return ListView.builder(
                          itemCount: zikrItems.length,
                          itemBuilder: (context, index) {
                            print('ZikrListPage: Building item $index: ${zikrItems[index].name}');
                            return _buildZikrCard(zikrItems[index], index);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZikrCard(ZikrItem zikr, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform( // Changed from elasticOut to easeOut
          (_animationController.value - (index * 0.05)).clamp(0.0, 1.0), // Reduced stagger from 0.1 to 0.05
        );
        
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)), // Reduced from 50 to 20
          child: Opacity(
            opacity: animationValue.clamp(0.0, 1.0), // Ensure opacity is within valid range
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _onZikrSelected(zikr),
                onTapDown: (_) => HapticFeedback.lightImpact(),
                child: Container(
                  constraints: BoxConstraints(minHeight: 100),
                  decoration: BoxDecoration(
                    gradient: zikr.gradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: zikr.gradient.colors[0].withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      
                      // Content
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    zikr.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    zikr.arabic,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white.withOpacity(0.9),
                                      fontFamily: 'Amiri',
                                      height: 1.4,
                                    ),
                                    textDirection: TextDirection.rtl,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    zikr.meaning,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: 12),
                            
                            // Count display
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${zikr.count}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ZikrItem {
  final String name;
  final String arabic;
  final String meaning;
  final LinearGradient gradient;
  final int count;

  ZikrItem({
    required this.name,
    required this.arabic,
    required this.meaning,
    required this.gradient,
    required this.count,
  });
}