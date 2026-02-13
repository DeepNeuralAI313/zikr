import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/app_localizations.dart';
import '../../core/theme.dart';

class JuzSelectionPage extends StatefulWidget {
  @override
  _JuzSelectionPageState createState() => _JuzSelectionPageState();
}

class _JuzSelectionPageState extends State<JuzSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<int> juzList = List.generate(30, (index) => index + 1);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800), // Reduced from 1200ms
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onJuzSelected(int juzNumber) {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(
      context,
      '/ruku-selection',
      arguments: {'juzNumber': juzNumber},
    );
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
          l10n.selectJuz,
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
            // Header section
            Text(
              l10n.chooseYourJuz,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.selectFrom30Juz,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? accentGrey : accentGreyDark,
              ),
            ),
            SizedBox(height: 32),
            
            // 5x6 Grid of Juz buttons - all same size
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final juzNumber = index + 1;
                  return _buildJuzButton(juzNumber, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuzButton(int juzNumber, int index) {
    final color = rotatingColors[index % rotatingColors.length];
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
              onTap: () => _onJuzSelected(juzNumber),
              onTapDown: (_) => HapticFeedback.lightImpact(),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? color.withOpacity(0.15)
                      : color.withOpacity(0.1),
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
                    '$juzNumber',
                    style: TextStyle(
                      fontSize: 22,
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