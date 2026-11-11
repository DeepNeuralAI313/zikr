import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'models.dart';

// Storage service for Zikr tracking - now using DatabaseService for counts
class ZikrStorageService {
  static const String _customZikrKey = 'custom_zikr';
  
  static ZikrStorageService? _instance;
  static ZikrStorageService get instance => _instance ??= ZikrStorageService._();
  
  final DatabaseService _db = DatabaseService();
  
  ZikrStorageService._();
  
  // Predefined Zikr items
  static const List<Map<String, String>> predefinedZikr = [
    {
      'name': 'La ilaha illallah Muhammadur Rasulullah ﷺ',
      'arabic': 'لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّهِ ﷺ',
      'meaning': 'There is no deity except Allah, Muhammad ﷺ is the Messenger of Allah',
    },
    {
      'name': 'Sallallahu alaihi wa ala alihi wasallam',
      'arabic': 'صَلَّى اللّٰهُ عَلَيْهِ وَعَلَى آلِهِ وَسَلَّمَ',
      'meaning': 'Peace and blessings of Allah be upon him and his family',
    },
    {
      'name': 'Astaghfirullaha alladhi la ilaha illa Huwa al-Hayyul-Qayyum wa atubu ilayh',
      'arabic': 'أَسْتَغْفِرُ اللّٰهَ الَّذِي لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      'meaning': 'I seek forgiveness from Allah, there is no deity except Him, the Ever-Living, the Sustainer, and I repent to Him',
    },
    {
      'name': 'SubhanAllahi walhamdulillahi wa la ilaha illallahu wallahu akbar wa la hawla wa la quwwata illa billahil aliyyil azim',
      'arabic': 'سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَآ اِلٰهَ اِلَّااللّٰهُ وَاللّٰهُ اَكْبَرُ ؕ وَلَآ حَوْلَ وَلَا قُوَّةَ اِلَّا بِاللّٰهِ الْعَلِىِّ الْعَظِيْمِ',
      'meaning': 'Glory be to Allah, all praise be to Allah, there is no deity except Allah, Allah is the Greatest, and there is no power or might except with Allah, the Most High, the Most Great',
    },
  ];
  
  // Add custom zikr
  Future<bool> addCustomZikr({
    required String name,
    required String arabic,
    required String meaning,
  }) async {
    try {
      name = name.trim();
      if (name.isEmpty || predefinedZikr.any((zikr) => zikr['name'] == name)) {
        return false;
      }
      final prefs = await SharedPreferences.getInstance();
      final customZikrJson = prefs.getString(_customZikrKey);
      
      List<Map<String, String>> customZikrs = [];
      if (customZikrJson != null) {
        final decoded = json.decode(customZikrJson) as List;
        customZikrs = decoded.map((e) => Map<String, String>.from(e)).toList();
      }
      
      // Check if zikr with same name already exists
      if (customZikrs.any((z) => z['name'] == name)) {
        return false; // Duplicate name
      }
      
      customZikrs.add({
        'name': name,
        'arabic': arabic,
        'meaning': meaning,
      });
      
      await prefs.setString(_customZikrKey, json.encode(customZikrs));
      return true;
    } catch (e) {
      print('Error adding custom zikr: $e');
      return false;
    }
  }
  
  // Get all custom zikrs
  Future<List<Map<String, String>>> getCustomZikrs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customZikrJson = prefs.getString(_customZikrKey);
      
      if (customZikrJson != null) {
        final decoded = json.decode(customZikrJson) as List;
        return decoded.map((e) => Map<String, String>.from(e)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting custom zikrs: $e');
      return [];
    }
  }
  
  // Get all zikrs (predefined + custom)
  Future<List<Map<String, String>>> getAllZikrs() async {
    final customZikrs = await getCustomZikrs();
    return [...predefinedZikr, ...customZikrs];
  }
  
  // Delete custom zikr
  Future<bool> deleteCustomZikr(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customZikrJson = prefs.getString(_customZikrKey);
      
      if (customZikrJson != null) {
        final decoded = json.decode(customZikrJson) as List;
        List<Map<String, String>> customZikrs = 
            decoded.map((e) => Map<String, String>.from(e)).toList();
        
        customZikrs.removeWhere((z) => z['name'] == name);
        
        await prefs.setString(_customZikrKey, json.encode(customZikrs));
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting custom zikr: $e');
      return false;
    }
  }
  
  // =================== ZIKR COUNTING (Database-based) ===================
  
  // Get current session count for a Zikr (automatically resets on new day)
  Future<int> getZikrCount(String zikrName) async {
    try {
      print('ZikrStorage: Getting count for $zikrName');
      final zikr = await _db.getZikrCounterByName(zikrName);
      if (zikr == null) {
        print('ZikrStorage: Zikr not found');
        return 0;
      }
      
      // Check if it's a new day and reset if needed
      await _db.checkAndResetDailyCount(zikr.id);
      
      // Re-fetch the counter after potential reset
      final updatedZikr = await _db.getZikrCounter(zikr.id);
      print('ZikrStorage: Found zikr: ${updatedZikr?.name}, sessionCount: ${updatedZikr?.sessionCount}');
      return updatedZikr?.sessionCount ?? 0;
    } catch (e, stackTrace) {
      print('Error getting Zikr count: $e');
      print('Stack trace: $stackTrace');
      return 0;
    }
  }
  
  // Get lifetime total for a Zikr (NEVER resets)
  Future<int> getLifetimeTotal(String zikrName) async {
    try {
      final zikr = await _db.getZikrCounterByName(zikrName);
      return zikr?.lifetimeTotal ?? 0;
    } catch (e) {
      print('Error getting lifetime total: $e');
      return 0;
    }
  }
  
  // Get today's total Zikr count (sum of today's sessions + current session, automatically resets on new day)
  Future<int> getTodayZikrCount(String zikrName) async {
    try {
      final zikr = await _db.getZikrCounterByName(zikrName);
      if (zikr == null) return 0;
      
      // Check if it's a new day and reset if needed
      await _db.checkAndResetDailyCount(zikr.id);
      
      return await _db.getTodayZikrTotal(zikr.id);
    } catch (e) {
      print('Error getting today\'s Zikr count: $e');
      return 0;
    }
  }
  
  // Increment Zikr count (session and lifetime)
  Future<bool> incrementZikrCount(String zikrName, int increment) async {
    try {
      print('ZikrStorage: Attempting to increment $zikrName by $increment');
      
      var zikr = await _db.getZikrCounterByName(zikrName);
      
      if (zikr == null) {
        print('ZikrStorage: Counter not found, creating it...');
        // Try to create the counter first
        await _db.incrementZikrCountByName(zikrName, 0); // This will create it
        zikr = await _db.getZikrCounterByName(zikrName);
        
        if (zikr == null) {
          print('ZikrStorage: Failed to create counter for $zikrName');
          return false;
        }
      }
      
      print('ZikrStorage: Found counter with ID ${zikr.id}');
      await _db.incrementZikrCount(zikr.id, increment);
      print('ZikrStorage: Successfully incremented counter');
      return true;
    } catch (e, stackTrace) {
      print('Error incrementing Zikr count: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }
  
  // Reset session count and save as completed session
  // Counts also roll over automatically when a new day begins.
  Future<bool> resetZikrSession(String zikrName) async {
    try {
      final zikr = await _db.getZikrCounterByName(zikrName);
      if (zikr == null) return false;
      
      await _db.resetZikrSession(zikr.id);
      return true;
    } catch (e) {
      print('Error resetting Zikr session: $e');
      return false;
    }
  }
  
  // Get all Zikr counts (session counts)
  Future<Map<String, int>> getAllZikrCounts() async {
    try {
      print('ZikrStorage: Getting all zikr counts...');
      final existing = await _db.getZikrCounters();
      for (final counter in existing) {
        await _db.checkAndResetDailyCount(counter.id);
      }
      final counters = await _db.getZikrCounters();
      print('ZikrStorage: Found ${counters.length} counters');
      
      for (var counter in counters) {
        print('  - ${counter.name}: session=${counter.sessionCount}, lifetime=${counter.lifetimeTotal}');
      }
      
      return {for (var counter in counters) counter.name: counter.sessionCount};
    } catch (e, stackTrace) {
      print('Error getting all Zikr counts: $e');
      print('Stack trace: $stackTrace');
      return {};
    }
  }
  
  // Get all lifetime totals
  Future<Map<String, int>> getAllLifetimeTotals() async {
    try {
      final counters = await _db.getZikrCounters();
      return {for (var counter in counters) counter.name: counter.lifetimeTotal};
    } catch (e) {
      print('Error getting all lifetime totals: $e');
      return {};
    }
  }
  
  // Get today's total across all Zikrs
  Future<int> getTodayTotalZikrCount() async {
    try {
      return await _db.getTodayTotalAllZikr();
    } catch (e) {
      print('Error getting today\'s total: $e');
      return 0;
    }
  }
  
  // Get yesterday's total across all Zikrs
  Future<int> getYesterdayTotalZikrCount() async {
    try {
      return await _db.getYesterdayTotalAllZikr();
    } catch (e) {
      print('Error getting yesterday\'s total: $e');
      return 0;
    }
  }
  
  // Get Zikr history for last N days (for charts)
  Future<Map<String, int>> getZikrHistory(String zikrName, {int days = 7}) async {
    try {
      final zikr = await _db.getZikrCounterByName(zikrName);
      if (zikr == null) return {};
      
      return await _db.getDailyTotals(zikr.id, days: days);
    } catch (e) {
      print('Error getting zikr history: $e');
      return {};
    }
  }
  
  // Get full session history
  Future<List<ZikrSession>> getZikrSessions(String zikrName, {int? limit}) async {
    try {
      final zikr = await _db.getZikrCounterByName(zikrName);
      if (zikr == null) return [];
      
      return await _db.getZikrSessions(zikr.id, limit: limit);
    } catch (e) {
      print('Error getting zikr sessions: $e');
      return [];
    }
  }
  
  // Get monthly totals
  Future<Map<String, int>> getMonthlyHistory(String zikrName, {int months = 12}) async {
    try {
      final zikr = await _db.getZikrCounterByName(zikrName);
      if (zikr == null) return {};
      
      return await _db.getMonthlyTotals(zikr.id, months: months);
    } catch (e) {
      print('Error getting monthly history: $e');
      return {};
    }
  }
}