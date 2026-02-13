import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/app_localizations.dart';
import '../../core/theme.dart';
import '../../core/database_service.dart';

class RukuSelectionPage extends StatefulWidget {
  final int juzNumber;
  
  const RukuSelectionPage({Key? key, required this.juzNumber}) : super(key: key);

  @override
  _RukuSelectionPageState createState() => _RukuSelectionPageState();
}

class _RukuSelectionPageState extends State<RukuSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<int> rukuList = [];
  Map<String, dynamic>? quranData;

  @override
  void initState() {
    super.initState();
    _loadRukuData();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  Future<void> _loadRukuData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quran_data.json');
      quranData = json.decode(jsonString);
      
      int rukuCount = _getRukuCountForJuz(widget.juzNumber);
      setState(() {
        rukuList = List.generate(rukuCount, (index) => index + 1);
      });
    } catch (e) {
      print('Error loading quran data: $e');
      // Fallback to default count if file not found
      setState(() {
        rukuList = List.generate(18, (index) => index + 1);
      });
    }
  }

  int _getRukuCountForJuz(int juzNumber) {
    if (quranData != null && quranData!.containsKey('${widget.juzNumber}')) {
      return quranData!['${widget.juzNumber}'] ?? 18;
    }
    return 18; // Default fallback
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onRukuSelected(int rukuNumber) {
    HapticFeedback.mediumImpact();
    _saveRukuProgress(rukuNumber);
  }

  Future<void> _saveRukuProgress(int rukuNumber) async {
    try {
      final database = DatabaseService();
      await database.saveQuranProgress(
        juzNumber: widget.juzNumber,
        rukuNumber: rukuNumber,
        // No ayahNumber - just saving Ruku progress
      );
      
      Navigator.popUntil(context, (route) => route.isFirst);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Progress saved: Juz ${widget.juzNumber}, Ruku $rukuNumber',
          ),
          backgroundColor: accentGreen,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving progress: $e'),
          backgroundColor: accentPink,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          '${l10n.selectRuku} – ${l10n.juz} ${widget.juzNumber}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              l10n.chooseRuku,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.rukusInJuz(rukuList.length, widget.juzNumber),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? accentGrey : accentGreyDark,
              ),
            ),
            SizedBox(height: 32),
            
            // Grid of Ruku buttons
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: rukuList.length,
                itemBuilder: (context, index) {
                  final rukuNumber = rukuList[index];
                  return _buildRukuButton(rukuNumber, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRukuButton(int rukuNumber, int index) {
    final colorIndex = index % rotatingColors.length;
    final color = rotatingColors[colorIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(
          (_animationController.value - (index * 0.015)).clamp(0.0, 1.0),
        );
        
        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animationValue)),
            child: GestureDetector(
              onTap: () => _onRukuSelected(rukuNumber),
              onTapDown: (_) => HapticFeedback.lightImpact(),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? color.withOpacity(0.12)
                      : color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(isDark ? 0.4 : 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$rukuNumber',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: color,
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
}