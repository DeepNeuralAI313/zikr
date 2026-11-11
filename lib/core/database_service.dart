import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';
import 'services/quran_data_service.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Database is not supported on web platform');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Database is not supported on web platform');
    }
    String path = join(await getDatabasesPath(), 'zikr_quran.db');
    print('DB: Initializing database at $path');

    final db = await openDatabase(
      path,
      version: 5, // Bookmarks and completed reading are tracked separately.
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    print('DB: Database opened successfully');

    // Check if we have any zikr counters
    final counters = await db.query('zikr_counters');
    print('DB: Found ${counters.length} zikr counters in database');

    if (counters.isEmpty) {
      print('DB: No counters found, inserting initial data');
      await _insertInitialZikrData(db);
      final newCounters = await db.query('zikr_counters');
      print('DB: After insertion, found ${newCounters.length} counters');
    }

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createCompletionTable(db);
    // Quran progress table (Juz-Ruku-Ayah based)
    await db.execute('''
      CREATE TABLE quran_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        juzNumber INTEGER NOT NULL,
        rukuNumber INTEGER NOT NULL,
        ayahNumber INTEGER,
        location TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Zikr counters table (session-based)
    await db.execute('''
      CREATE TABLE zikr_counters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        arabic TEXT NOT NULL,
        meaning TEXT NOT NULL,
        sessionCount INTEGER NOT NULL DEFAULT 0,
        lifetimeTotal INTEGER NOT NULL DEFAULT 0,
        target INTEGER NOT NULL,
        lastUpdated TEXT NOT NULL,
        lastResetDate TEXT NOT NULL
      )
    ''');

    // Zikr sessions table for complete history tracking
    await db.execute('''
      CREATE TABLE zikr_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        zikrId INTEGER NOT NULL,
        count INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (zikrId) REFERENCES zikr_counters (id)
      )
    ''');

    // Insert initial data
    await _insertInitialZikrData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) await _createCompletionTable(db);
    if (oldVersion < 2) {
      // Drop old tables and recreate with new schema
      await db.execute('DROP TABLE IF EXISTS quran_progress');
      await db.execute('DROP TABLE IF EXISTS zikr_counters');

      // Recreate tables with new schema
      await _onCreate(db, newVersion);
    }

    if (oldVersion < 3) {
      // Migrate to session-based tracking
      // Get existing data if tables exist
      List<Map<String, dynamic>> existingZikrs = [];
      List<Map<String, dynamic>> existingHistory = [];

      try {
        existingZikrs = await db.query('zikr_counters');
      } catch (e) {
        print('No existing zikr_counters table: $e');
      }

      try {
        existingHistory = await db.query('zikr_history');
      } catch (e) {
        print('No existing zikr_history table: $e');
      }

      // Drop old tables
      await db.execute('DROP TABLE IF EXISTS zikr_history');
      await db.execute('DROP TABLE IF EXISTS zikr_counters');

      // Create new tables
      await db.execute('''
        CREATE TABLE zikr_counters(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          arabic TEXT NOT NULL,
          meaning TEXT NOT NULL,
          sessionCount INTEGER NOT NULL DEFAULT 0,
          lifetimeTotal INTEGER NOT NULL DEFAULT 0,
          target INTEGER NOT NULL,
          lastUpdated TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE zikr_sessions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          zikrId INTEGER NOT NULL,
          count INTEGER NOT NULL,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (zikrId) REFERENCES zikr_counters (id)
        )
      ''');

      // Migrate data if exists
      if (existingZikrs.isNotEmpty) {
        for (var zikr in existingZikrs) {
          final count = zikr['count'] as int? ?? 0;
          await db.insert('zikr_counters', {
            'name': zikr['name'],
            'arabic': zikr['arabic'],
            'meaning': zikr['meaning'],
            'sessionCount': 0,
            'lifetimeTotal': count,
            'target': zikr['target'],
            'lastUpdated': zikr['lastUpdated'],
          });
        }

        // Migrate history as sessions
        for (var history in existingHistory) {
          await db.insert('zikr_sessions', {
            'zikrId': history['zikrId'],
            'count': history['count'],
            'timestamp': '${history['date']}T12:00:00.000',
          });
        }
      } else {
        // No existing data, insert initial data
        await _insertInitialZikrData(db);
      }
    }

    if (oldVersion < 4) {
      // Add lastResetDate column for automatic daily reset
      try {
        await db.execute(
          'ALTER TABLE zikr_counters ADD COLUMN lastResetDate TEXT DEFAULT ""',
        );

        // Set lastResetDate to today for all existing counters
        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        await db.execute('UPDATE zikr_counters SET lastResetDate = ?', [
          todayStr,
        ]);

        print('DB: Added lastResetDate column for daily reset tracking');
      } catch (e) {
        print('DB: Error adding lastResetDate column: $e');
      }
    }
  }

  Future<void> _insertInitialZikrData(Database db) async {
    final zikrs = [
      {
        "name": "La ilaha illallah Muhammadur Rasulullah ﷺ",
        "arabic": "لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّهِ ﷺ",
        "meaning":
            "There is no deity except Allah, Muhammad ﷺ is the Messenger of Allah",
        "target": 1,
      },
      {
        "name": "Sallallahu alaihi wa ala alihi wasallam",
        "arabic": "صَلَّى اللّٰهُ عَلَيْهِ وَعَلَى آلِهِ وَسَلَّمَ",
        "meaning": "Peace and blessings of Allah be upon him and his family",
        "target": 100,
      },
      {
        "name":
            "Astaghfirullaha alladhi la ilaha illa Huwa al-Hayyul-Qayyum wa atubu ilayh",
        "arabic":
            "أَسْتَغْفِرُ اللّٰهَ الَّذِي لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ",
        "meaning":
            "I seek forgiveness from Allah, there is no deity except Him, the Ever-Living, the Sustainer, and I repent to Him",
        "target": 100,
      },
      {
        "name":
            "SubhanAllahi walhamdulillahi wa la ilaha illallahu wallahu akbar wa la hawla wa la quwwata illa billahil aliyyil azim",
        "arabic":
            "سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَآ اِلٰهَ اِلَّااللّٰهُ وَاللّٰهُ اَكْبَرُ ؕ وَلَآ حَوْلَ وَلَا قُوَّةَ اِلَّا بِاللّٰهِ الْعَلِىِّ الْعَظِيْمِ",
        "meaning":
            "Glory be to Allah, all praise be to Allah, there is no deity except Allah, Allah is the Greatest, and there is no power or might except with Allah, the Most High, the Most Great",
        "target": 100,
      },
    ];

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    for (var zikr in zikrs) {
      await db.insert('zikr_counters', {
        'name': zikr['name'],
        'arabic': zikr['arabic'],
        'meaning': zikr['meaning'],
        'sessionCount': 0,
        'lifetimeTotal': 0,
        'target': zikr['target'],
        'lastUpdated': DateTime.now().toIso8601String(),
        'lastResetDate': todayStr,
      });
    }
  }

  // =================== QURAN METHODS ===================

  /// Save Quran reading progress
  Future<void> saveQuranProgress({
    required int juzNumber,
    required int rukuNumber,
    int? ayahNumber,
  }) async {
    final db = await database;

    String location;
    if (ayahNumber != null) {
      location = "Juz $juzNumber, Ruku $rukuNumber, Ayah $ayahNumber";
    } else {
      location = "Juz $juzNumber, Ruku $rukuNumber";
    }

    final progress = QuranProgress(
      juzNumber: juzNumber,
      rukuNumber: rukuNumber,
      ayahNumber: ayahNumber,
      location: location,
      timestamp: DateTime.now(),
    );

    await db.insert('quran_progress', progress.toMap());
  }

  static Future<void> _createCompletionTable(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS quran_completions(
      juzNumber INTEGER NOT NULL,
      rukuNumber INTEGER NOT NULL,
      completedDate TEXT NOT NULL,
      completedAt TEXT NOT NULL,
      PRIMARY KEY(juzNumber, rukuNumber, completedDate)
    )''');
  }

  Future<void> markRukuCompleted({
    required int juzNumber,
    required int rukuNumber,
    DateTime? completedAt,
  }) async {
    final data = QuranDataService.instance;
    await data.loadData();
    if (juzNumber < 1 ||
        juzNumber > 30 ||
        rukuNumber < 1 ||
        rukuNumber > data.getRukuCount(juzNumber)) {
      throw ArgumentError('Invalid Quran location');
    }
    final now = completedAt ?? DateTime.now();
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('quran_completions', {
        'juzNumber': juzNumber,
        'rukuNumber': rukuNumber,
        'completedDate': now.toIso8601String().split('T').first,
        'completedAt': now.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      // Completing a ruku also updates the resume position, atomically.
      await txn.insert(
        'quran_progress',
        QuranProgress(
          juzNumber: juzNumber,
          rukuNumber: rukuNumber,
          location: 'Juz $juzNumber, Ruku $rukuNumber',
          timestamp: now,
        ).toMap(),
      );
    });
  }

  Future<Set<String>> completedRukuKeys({String? date}) async {
    final db = await database;
    final rows = await db.query(
      'quran_completions',
      distinct: true,
      columns: ['juzNumber', 'rukuNumber'],
      where: date == null ? null : 'completedDate = ?',
      whereArgs: date == null ? null : [date],
    );
    return rows
        .map((row) => '${row['juzNumber']}:${row['rukuNumber']}')
        .toSet();
  }

  Future<void> undoRukuCompletion(int juzNumber, int rukuNumber) async {
    final db = await database;
    await db.delete(
      'quran_completions',
      where: 'juzNumber = ? AND rukuNumber = ? AND completedDate = ?',
      whereArgs: [
        juzNumber,
        rukuNumber,
        DateTime.now().toIso8601String().split('T').first,
      ],
    );
  }

  /// Get the latest Quran reading progress
  Future<QuranProgress?> getLatestQuranProgress() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quran_progress',
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return QuranProgress.fromMap(maps.first);
  }

  /// Get all Quran reading history
  Future<List<QuranProgress>> getQuranHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quran_progress',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => QuranProgress.fromMap(maps[i]));
  }

  // =================== ZIKR METHODS ===================

  /// Get all Zikr counters
  Future<List<ZikrCounter>> getZikrCounters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('zikr_counters');
    return List.generate(maps.length, (i) => ZikrCounter.fromMap(maps[i]));
  }

  /// Get a specific Zikr counter by ID
  Future<ZikrCounter?> getZikrCounter(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'zikr_counters',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ZikrCounter.fromMap(maps.first);
  }

  String _dateKey(DateTime date) => date.toIso8601String().split('T').first;

  // Run inside the same transaction as reads/writes so rollover cannot be saved twice.
  Future<void> _rollOverDailyCount(
    DatabaseExecutor db,
    int id,
    DateTime now,
  ) async {
    final rows = await db.query(
      'zikr_counters',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return;
    final counter = ZikrCounter.fromMap(rows.first);
    final today = _dateKey(now);
    if (counter.lastResetDate == today) return;
    if (counter.sessionCount > 0) {
      await db.insert('zikr_sessions', {
        'zikrId': id,
        'count': counter.sessionCount,
        'timestamp': counter.lastUpdated.toIso8601String(),
      });
    }
    await db.update(
      'zikr_counters',
      {
        'sessionCount': 0,
        'lastResetDate': today,
        'lastUpdated': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Archive an unfinished session on its actual activity date.
  Future<void> checkAndResetDailyCount(int zikrId) async {
    final db = await database;
    await db.transaction(
      (txn) => _rollOverDailyCount(txn, zikrId, DateTime.now()),
    );
  }

  /// Get a specific Zikr counter by name
  Future<ZikrCounter?> getZikrCounterByName(String zikrName) async {
    try {
      final db = await database;
      print('DB: Querying for zikr: $zikrName');

      final List<Map<String, dynamic>> maps = await db.query(
        'zikr_counters',
        where: 'name = ?',
        whereArgs: [zikrName],
      );

      print('DB: Found ${maps.length} results');
      if (maps.isNotEmpty) {
        print('DB: First result: ${maps.first}');
      }

      if (maps.isEmpty) return null;
      return ZikrCounter.fromMap(maps.first);
    } catch (e, stackTrace) {
      print('DB Error getting zikr by name: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Increment atomically, including when taps arrive quickly or cross midnight.
  Future<void> incrementZikrCount(int id, int increment) async {
    if (increment <= 0) return;
    final db = await database;
    await db.transaction((txn) async {
      final now = DateTime.now();
      await _rollOverDailyCount(txn, id, now);
      await txn.rawUpdate(
        '''UPDATE zikr_counters
        SET sessionCount = sessionCount + ?, lifetimeTotal = lifetimeTotal + ?,
            lastUpdated = ? WHERE id = ?''',
        [increment, increment, now.toIso8601String(), id],
      );
    });
  }

  /// Increment Zikr count by name
  Future<void> incrementZikrCountByName(String zikrName, int increment) async {
    final current = await getZikrCounterByName(zikrName);
    if (current != null) {
      await incrementZikrCount(current.id, increment);
    } else {
      // Counter doesn't exist, try to create it from predefined list
      await _ensureZikrCounterExists(zikrName);
      final newCounter = await getZikrCounterByName(zikrName);
      if (newCounter != null) {
        await incrementZikrCount(newCounter.id, increment);
      }
    }
  }

  /// Ensure a zikr counter exists in the database
  Future<void> _ensureZikrCounterExists(String zikrName) async {
    final db = await database;

    // Check if it exists
    final existing = await getZikrCounterByName(zikrName);
    if (existing != null) return;

    // Try to find in predefined list
    const predefinedZikrs = [
      {
        "name": "La ilaha illallah Muhammadur Rasulullah ﷺ",
        "arabic": "لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّهِ ﷺ",
        "meaning":
            "There is no deity except Allah, Muhammad ﷺ is the Messenger of Allah",
        "target": 1,
      },
      {
        "name": "Sallallahu alaihi wa ala alihi wasallam",
        "arabic": "صَلَّى اللّٰهُ عَلَيْهِ وَعَلَى آلِهِ وَسَلَّمَ",
        "meaning": "Peace and blessings of Allah be upon him and his family",
        "target": 100,
      },
      {
        "name":
            "Astaghfirullaha alladhi la ilaha illa Huwa al-Hayyul-Qayyum wa atubu ilayh",
        "arabic":
            "أَسْتَغْفِرُ اللّٰهَ الَّذِي لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ",
        "meaning":
            "I seek forgiveness from Allah, there is no deity except Him, the Ever-Living, the Sustainer, and I repent to Him",
        "target": 100,
      },
      {
        "name":
            "SubhanAllahi walhamdulillahi wa la ilaha illallahu wallahu akbar wa la hawla wa la quwwata illa billahil aliyyil azim",
        "arabic":
            "سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَآ اِلٰهَ اِلَّااللّٰهُ وَاللّٰهُ اَكْبَرُ ؕ وَلَآ حَوْلَ وَلَا قُوَّةَ اِلَّا بِاللّٰهِ الْعَلِىِّ الْعَظِيْمِ",
        "meaning":
            "Glory be to Allah, all praise be to Allah, there is no deity except Allah, Allah is the Greatest, and there is no power or might except with Allah, the Most High, the Most Great",
        "target": 100,
      },
    ];

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    for (var zikr in predefinedZikrs) {
      if (zikr['name'] == zikrName) {
        await db.insert('zikr_counters', {
          'name': zikr['name'],
          'arabic': zikr['arabic'],
          'meaning': zikr['meaning'],
          'sessionCount': 0,
          'lifetimeTotal': 0,
          'target': zikr['target'],
          'lastUpdated': DateTime.now().toIso8601String(),
          'lastResetDate': todayStr,
        });
        print('Created missing zikr counter: $zikrName');
        return;
      }
    }

    // If not found in predefined, create a generic one
    await db.insert('zikr_counters', {
      'name': zikrName,
      'arabic': zikrName,
      'meaning': '',
      'sessionCount': 0,
      'lifetimeTotal': 0,
      'target': 100,
      'lastUpdated': DateTime.now().toIso8601String(),
      'lastResetDate': todayStr,
    });
    print('Created generic zikr counter: $zikrName');
  }

  /// Archive and clear a session atomically without changing its lifetime total.
  Future<void> resetZikrSession(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      final now = DateTime.now();
      await _rollOverDailyCount(txn, id, now);
      final rows = await txn.query(
        'zikr_counters',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rows.isEmpty) return;
      final current = ZikrCounter.fromMap(rows.first);
      if (current.sessionCount == 0) return;
      await txn.insert('zikr_sessions', {
        'zikrId': id,
        'count': current.sessionCount,
        'timestamp': now.toIso8601String(),
      });
      await txn.update(
        'zikr_counters',
        {'sessionCount': 0, 'lastUpdated': now.toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  /// Update Zikr target
  Future<void> updateZikrTarget(int id, int newTarget) async {
    final db = await database;
    await db.update(
      'zikr_counters',
      {'target': newTarget, 'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get lifetime total for a Zikr (never resets)
  Future<int> getLifetimeTotal(int zikrId) async {
    final zikr = await getZikrCounter(zikrId);
    return zikr?.lifetimeTotal ?? 0;
  }

  /// Get today's total Zikr count (sum of all today's sessions + current session)
  Future<int> getTodayZikrTotal(int zikrId) async {
    await checkAndResetDailyCount(zikrId);
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day + 1,
    ).toIso8601String();

    // Get completed sessions from today
    final result = await db.rawQuery(
      '''
      SELECT SUM(count) as total
      FROM zikr_sessions
      WHERE zikrId = ? AND timestamp >= ? AND timestamp < ?
    ''',
      [zikrId, startOfDay, endOfDay],
    );

    final sessionsTotal = result.first['total'] as int? ?? 0;

    // Add current session count
    final current = await getZikrCounter(zikrId);
    final currentSession = current?.sessionCount ?? 0;

    return sessionsTotal + currentSession;
  }

  /// Get all sessions for a Zikr (complete history)
  Future<List<ZikrSession>> getZikrSessions(int zikrId, {int? limit}) async {
    await checkAndResetDailyCount(zikrId);
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'zikr_sessions',
      where: 'zikrId = ?',
      whereArgs: [zikrId],
      orderBy: 'timestamp DESC, id DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => ZikrSession.fromMap(maps[i]));
  }

  /// Get daily totals for graphing (aggregated by date)
  Future<Map<String, int>> getDailyTotals(int zikrId, {int days = 7}) async {
    if (days <= 0) return {};
    await checkAndResetDailyCount(zikrId);
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days - 1));
    final startDateStr = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    ).toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT 
        DATE(timestamp) as date,
        SUM(count) as total
      FROM zikr_sessions
      WHERE zikrId = ? AND timestamp >= ?
      GROUP BY DATE(timestamp)
      ORDER BY date DESC
    ''',
      [zikrId, startDateStr],
    );

    final now = DateTime.now();
    final Map<String, int> dailyTotals = {
      for (var i = 0; i < days; i++)
        _dateKey(DateTime(now.year, now.month, now.day - i)): 0,
    };
    for (var row in result) {
      final date = row['date'] as String;
      final total = row['total'] as int;
      if (dailyTotals.containsKey(date)) dailyTotals[date] = total;
    }

    final current = await getZikrCounter(zikrId);
    final today = _dateKey(now);
    dailyTotals[today] =
        (dailyTotals[today] ?? 0) + (current?.sessionCount ?? 0);
    return dailyTotals;
  }

  /// Get monthly history
  Future<Map<String, int>> getMonthlyTotals(
    int zikrId, {
    int months = 12,
  }) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: months * 30));
    final startDateStr = startDate.toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT 
        strftime('%Y-%m', timestamp) as month,
        SUM(count) as total
      FROM zikr_sessions
      WHERE zikrId = ? AND timestamp >= ?
      GROUP BY strftime('%Y-%m', timestamp)
      ORDER BY month DESC
    ''',
      [zikrId, startDateStr],
    );

    final Map<String, int> monthlyTotals = {};
    for (var row in result) {
      final month = row['month'] as String;
      final total = row['total'] as int;
      monthlyTotals[month] = total;
    }

    return monthlyTotals;
  }

  /// Get today's total across all Zikrs
  Future<int> getTodayTotalAllZikr() async {
    for (final counter in await getZikrCounters()) {
      await checkAndResetDailyCount(counter.id);
    }
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day + 1,
    ).toIso8601String();

    // Get completed sessions
    final result = await db.rawQuery(
      '''
      SELECT SUM(count) as total
      FROM zikr_sessions
      WHERE timestamp >= ? AND timestamp < ?
    ''',
      [startOfDay, endOfDay],
    );

    final sessionsTotal = result.first['total'] as int? ?? 0;

    // Add all current session counts
    final counters = await getZikrCounters();
    final currentTotal = counters.fold<int>(
      0,
      (sum, zikr) => sum + zikr.sessionCount,
    );

    return sessionsTotal + currentTotal;
  }

  /// Get yesterday's total across all Zikrs
  Future<int> getYesterdayTotalAllZikr() async {
    for (final counter in await getZikrCounters()) {
      await checkAndResetDailyCount(counter.id);
    }
    final db = await database;
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    final startOfDay = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day + 1,
    ).toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT SUM(count) as total
      FROM zikr_sessions
      WHERE timestamp >= ? AND timestamp < ?
    ''',
      [startOfDay, endOfDay],
    );

    return result.first['total'] as int? ?? 0;
  }

  // Legacy methods for backward compatibility
  Future<void> updateZikrCount(int id, int newCount) async {
    await incrementZikrCount(id, newCount);
  }

  Future<void> resetZikrCount(int id) async {
    await resetZikrSession(id);
  }

  Future<List<ZikrHistory>> getZikrHistory(int zikrId, {int? limitDays}) async {
    return await getZikrSessions(zikrId, limit: limitDays);
  }

  Future<int> getTodayTotalZikrCount() async {
    return await getTodayTotalAllZikr();
  }

  Future<int> getYesterdayTotalZikrCount() async {
    return await getYesterdayTotalAllZikr();
  }
}
