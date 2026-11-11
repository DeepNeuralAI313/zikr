import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'zikr_chart.dart';
import '../../core/database_service.dart';
import '../../core/models.dart';

class ZikrScreen extends StatefulWidget {
  @override
  _ZikrScreenState createState() => _ZikrScreenState();
}

class _ZikrScreenState extends State<ZikrScreen> {
  final DatabaseService _db = DatabaseService();
  List<ZikrCounter> _zikrCounters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadZikrCounters();
  }

  Future<void> _loadZikrCounters() async {
    try {
      final counters = await _db.getZikrCounters();
      setState(() {
        _zikrCounters = counters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Zikr counters: $e')),
      );
    }
  }

  Future<void> _incrementCounter(ZikrCounter zikr, int increment) async {
    final newCount = zikr.sessionCount + increment;
    try {
      await _db.incrementZikrCount(zikr.id, increment);
      await _loadZikrCounters();
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
      // Show completion celebration
      if (zikr.sessionCount < zikr.target && newCount >= zikr.target) {
        _showCompletionDialog(zikr.name);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating counter: $e')),
      );
    }
  }

  Future<void> _resetCounter(ZikrCounter zikr) async {
    try {
      await _db.resetZikrCount(zikr.id);
      await _loadZikrCounters();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${zikr.name} counter reset')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting counter: $e')),
      );
    }
  }

  Future<void> _updateTarget(ZikrCounter zikr) async {
    final controller = TextEditingController(text: zikr.target.toString());
    
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${zikr.name}'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New target',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTarget = int.tryParse(controller.text) ?? 0;
              if (newTarget > 0) {
                Navigator.pop(context, newTarget);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      try {
        await _db.updateZikrTarget(zikr.id, result);
        await _loadZikrCounters();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating target: $e')),
        );
      }
    }
  }

  void _showCompletionDialog(String zikrName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 Target Achieved!'),
        content: Text('Congratulations! You have completed your $zikrName target!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Alhamdulillah'),
          ),
        ],
      ),
    );
  }

  void _showZikrOptions(ZikrCounter zikr) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              zikr.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Update Target'),
              onTap: () {
                Navigator.pop(context);
                _updateTarget(zikr);
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Reset Counter'),
              onTap: () {
                Navigator.pop(context);
                _resetCounter(zikr);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zikr Tracker'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadZikrCounters,
              child: _zikrCounters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No Zikr counters found'),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadZikrCounters,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: _zikrCounters
                            .map((zikr) => Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: ZikrProgressChart(
                                    zikr: zikr,
                                    onIncrement: _incrementCounter,
                                    onLongPress: _showZikrOptions,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
            ),
    );
  }
}