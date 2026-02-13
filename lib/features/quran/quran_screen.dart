import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database_service.dart';
import '../../core/models.dart';

class QuranScreen extends StatefulWidget {
  @override
  _QuranScreenState createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final DatabaseService _db = DatabaseService();
  List<QuranProgress> _surahs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuranProgress();
  }

  Future<void> _loadQuranProgress() async {
    try {
      final surahs = await _db.getQuranProgress();
      setState(() {
        _surahs = surahs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Quran progress: $e')),
      );
    }
  }

  Future<void> _updateProgress(QuranProgress surah, int newReadAyahs) async {
    try {
      await _db.updateQuranProgress(surah.surahNumber, newReadAyahs);
      await _loadQuranProgress();
      
      if (newReadAyahs >= surah.totalAyahs) {
        _showCompletionDialog(surah.surahName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating progress: $e')),
      );
    }
  }

  void _showCompletionDialog(String surahName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 Congratulations!'),
        content: Text('You have completed reading Surah $surahName!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Alhamdulillah'),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(QuranProgress surah) {
    final controller = TextEditingController(text: surah.readAyahs.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Surah ${surah.surahName}'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ayahs read',
                hintText: 'Enter number of ayahs read',
                suffix: Text('/ ${surah.totalAyahs}'),
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
              final newValue = int.tryParse(controller.text) ?? 0;
              if (newValue >= 0 && newValue <= surah.totalAyahs) {
                _updateProgress(surah, newValue);
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quran Tracker'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadQuranProgress,
              child: _surahs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No Quran progress found'),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadQuranProgress,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _surahs.length,
                      itemBuilder: (context, index) {
                        final surah = _surahs[index];
                        return _buildSurahCard(surah);
                      },
                    ),
            ),
    );
  }

  Widget _buildSurahCard(QuranProgress surah) {
    final progress = surah.progress;
    final isCompleted = progress >= 1.0;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showProgressDialog(surah),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '${surah.surahNumber}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.surahName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${surah.readAyahs} / ${surah.totalAyahs} ayahs',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                ],
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Last read: ${DateFormat('MMM dd').format(surah.lastRead)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}