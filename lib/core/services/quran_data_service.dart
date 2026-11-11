import 'dart:convert';
import 'package:flutter/services.dart';

class QuranDataService {
  static QuranDataService? _instance;
  static QuranDataService get instance => _instance ??= QuranDataService._();
  
  QuranDataService._();

  Map<String, dynamic>? _quranData;
  bool _isLoaded = false;

  /// Load the Quran data from temp.json
  Future<void> loadData() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/quran_data.json');
      _quranData = json.decode(jsonString);
      _isLoaded = true;
      print('Quran data loaded successfully');
    } catch (e) {
      print('Error loading Quran data: $e');
      // Fallback to empty data structure
      _quranData = {};
    }
  }

  /// Get list of all Juz numbers (1-30)
  List<int> getJuzList() {
    if (_quranData == null) return List.generate(30, (index) => index + 1);
    
    List<int> juzList = [];
    for (String key in _quranData!.keys) {
      if (key.startsWith('juz_')) {
        int? juzNumber = int.tryParse(key.substring(4));
        if (juzNumber != null) {
          juzList.add(juzNumber);
        }
      }
    }
    juzList.sort();
    return juzList.isNotEmpty ? juzList : List.generate(30, (index) => index + 1);
  }

  /// Get list of Ruku for a specific Juz
  List<RukuInfo> getRukuList(int juzNumber) {
    if (_quranData == null) return [];

    String juzKey = 'juz_$juzNumber';
    Map<String, dynamic>? juzData = _quranData![juzKey];
    
    if (juzData == null) return [];

    List<RukuInfo> rukuList = [];
    for (String key in juzData.keys) {
      if (key.startsWith('ruku_')) {
        int? rukuNumber = int.tryParse(key.substring(5));
        if (rukuNumber != null) {
          List<dynamic> ayahRange = juzData[key];
          if (ayahRange.length >= 2) {
            rukuList.add(RukuInfo(
              number: rukuNumber,
              startAyah: ayahRange[0].toString(),
              endAyah: ayahRange[1].toString(),
            ));
          }
        }
      }
    }
    rukuList.sort((a, b) => a.number.compareTo(b.number));
    return rukuList;
  }

  /// Get Ayah range for a specific Juz and Ruku
  AyahRange? getAyahRange(int juzNumber, int rukuNumber) {
    if (_quranData == null) return null;

    String juzKey = 'juz_$juzNumber';
    String rukuKey = 'ruku_$rukuNumber';
    
    Map<String, dynamic>? juzData = _quranData![juzKey];
    if (juzData == null) return null;

    List<dynamic>? ayahRange = juzData[rukuKey];
    if (ayahRange == null || ayahRange.length < 2) return null;

    return AyahRange(
      startAyah: ayahRange[0].toString(),
      endAyah: ayahRange[1].toString(),
      juzNumber: juzNumber,
      rukuNumber: rukuNumber,
    );
  }

  /// Get total number of Ruku in a Juz
  int getRukuCount(int juzNumber) {
    final count = _quranData?['$juzNumber'];
    if (count is int) return count;
    return getRukuList(juzNumber).length;
  }

  /// Check if data is loaded
  bool get isDataLoaded => _isLoaded;

  /// Get formatted Juz name
  String getJuzName(int juzNumber) {
    return 'Juz $juzNumber';
  }

  /// Get formatted Ruku name
  String getRukuName(int rukuNumber) {
    return 'Ruku $rukuNumber';
  }
}

/// Model class for Ruku information
class RukuInfo {
  final int number;
  final String startAyah;
  final String endAyah;

  RukuInfo({
    required this.number,
    required this.startAyah,
    required this.endAyah,
  });

  String get displayText => 'Ruku $number\n$startAyah - $endAyah';
}

/// Model class for Ayah range information
class AyahRange {
  final String startAyah;
  final String endAyah;
  final int juzNumber;
  final int rukuNumber;

  AyahRange({
    required this.startAyah,
    required this.endAyah,
    required this.juzNumber,
    required this.rukuNumber,
  });

  String get displayText => '$startAyah - $endAyah';
  String get fullDisplayText => 'Juz $juzNumber, Ruku $rukuNumber\n$startAyah - $endAyah';
}
