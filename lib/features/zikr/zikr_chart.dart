import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import '../../core/models.dart';

class ZikrProgressChart extends StatelessWidget {
  final ZikrCounter zikr;
  final Function(ZikrCounter, int) onIncrement;
  final Function(ZikrCounter) onLongPress;

  const ZikrProgressChart({
    Key? key,
    required this.zikr,
    required this.onIncrement,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = zikr.progress;

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        child: InkWell(
          onLongPress: () => onLongPress(zikr),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              startDegreeOffset: -90,
                              sections: [
                                PieChartSectionData(
                                  value: value * 100,
                                  color: zikr.isCompleted 
                                      ? Colors.green 
                                      : Theme.of(context).primaryColor,
                                  radius: 16,
                                  title: '',
                                ),
                                PieChartSectionData(
                                  value: (1 - value) * 100,
                                  color: Colors.grey.shade300,
                                  radius: 16,
                                  title: '',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${zikr.sessionCount}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: zikr.isCompleted ? Colors.green : null,
                            ),
                          ),
                          Text(
                            "/${zikr.target}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (zikr.isCompleted)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Lottie.asset(
                              'assets/lottie/confetti.json',
                              repeat: false,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zikr.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        zikr.arabic,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Amiri', // Arabic font if available
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${zikr.sessionCount} / ${zikr.target}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildIncrementButton(context, '+1', () => onIncrement(zikr, 1)),
                          _buildIncrementButton(context, '+10', () => onIncrement(zikr, 10)),
                          _buildIncrementButton(context, '+33', () => onIncrement(zikr, 33)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keep the old function for backward compatibility
Widget zikrProgressChart(int count, int target) {
  final dummyZikr = ZikrCounter(
    id: 0,
    name: 'Durood Sharif',
    arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
    meaning: 'O Allah, send blessings upon Muhammad and the family of Muhammad',
    sessionCount: count,
    lifetimeTotal: count,
    target: target,
    lastUpdated: DateTime.now(),
  );
  
  return ZikrProgressChart(
    zikr: dummyZikr,
    onIncrement: (_, __) {},
    onLongPress: (_) {},
  );
}

Widget _buildIncrementButton(BuildContext context, String label, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: StadiumBorder(),
      textStyle: TextStyle(fontWeight: FontWeight.w600),
      minimumSize: Size(72, 40),
    ),
    child: Text(label),
  );
}