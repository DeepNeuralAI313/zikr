import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_service.dart';
import '../models.dart';
import 'quran_data_service.dart';
import 'routine_service.dart';
import 'adhkar_service.dart';
import 'reading_preferences.dart';

class BackupService {
  static const tables = [
    'zikr_counters',
    'zikr_sessions',
    'quran_progress',
    'quran_completions',
  ];
  static const preferenceKeys = [
    'custom_zikr',
    RoutineService.key,
    'adhkar_v1',
    AdhkarService.collectionsKey,
    ReadingPreferences.key,
  ];

  static Future<Map<String, dynamic>> snapshot() async {
    final db = await DatabaseService().database;
    final prefs = await SharedPreferences.getInstance();
    final data = await db.transaction(
      (txn) async => {
        for (final table in tables) table: await txn.query(table),
      },
    );
    return {
      'app': 'dhikr-quran-tracker',
      'version': 2,
      'createdAt': DateTime.now().toIso8601String(),
      'tables': data,
      'preferences': {
        for (final key in preferenceKeys) key: prefs.getString(key),
      },
    };
  }

  static Future<String> exportJson() async =>
      const JsonEncoder.withIndent('  ').convert(await snapshot());

  static void validate(Map<String, dynamic> backup) {
    void require(bool condition) {
      if (!condition) {
        throw const FormatException('Invalid or incompatible backup');
      }
    }

    require(
      backup['app'] == 'dhikr-quran-tracker' &&
          [1, 2].contains(backup['version']),
    );
    final data = backup['tables'] as Map<String, dynamic>;
    // Legacy backups contain bookmarks only; never infer completed reading.
    if (backup['version'] == 1)
      data.putIfAbsent('quran_completions', () => <dynamic>[]);
    for (final table in tables) {
      require(data[table] is List && (data[table] as List).length <= 1000000);
    }
    final ids = <int>{};
    final names = <String>{};
    for (final row in data['zikr_counters'] as List) {
      final c = ZikrCounter.fromMap(Map<String, dynamic>.from(row));
      require(
        c.id > 0 &&
            ids.add(c.id) &&
            c.name.trim().isNotEmpty &&
            names.add(c.name) &&
            c.sessionCount >= 0 &&
            c.lifetimeTotal >= c.sessionCount &&
            c.target >= 0,
      );
      require(
        c.lastResetDate != null &&
            dayKey(DateTime.parse(c.lastResetDate!)) == c.lastResetDate,
      );
    }
    final sessionIds = <int>{};
    for (final row in data['zikr_sessions'] as List) {
      final s = ZikrSession.fromMap(Map<String, dynamic>.from(row));
      require(
        s.id != null &&
            s.id! > 0 &&
            sessionIds.add(s.id!) &&
            ids.contains(s.zikrId) &&
            s.count >= 0,
      );
    }
    final progressIds = <int>{};
    for (final row in data['quran_progress'] as List) {
      final p = QuranProgress.fromMap(Map<String, dynamic>.from(row));
      require(
        p.id != null &&
            p.id! > 0 &&
            progressIds.add(p.id!) &&
            p.juzNumber >= 1 &&
            p.juzNumber <= 30 &&
            p.rukuNumber >= 1 &&
            p.rukuNumber <=
                QuranDataService.instance.getRukuCount(p.juzNumber) &&
            (p.ayahNumber == null || p.ayahNumber! > 0),
      );
    }
    final prefs = backup['preferences'] as Map<String, dynamic>;
    final completionKeys = <String>{};
    for (final row in data['quran_completions'] as List) {
      final j = row['juzNumber'], r = row['rukuNumber'];
      require(
        j is int &&
            j >= 1 &&
            j <= 30 &&
            r is int &&
            r >= 1 &&
            r <= QuranDataService.instance.getRukuCount(j),
      );
      require(
        row['completedDate'] is String &&
            dayKey(DateTime.parse(row['completedDate'])) ==
                row['completedDate'],
      );
      require(
        row['completedAt'] is String &&
            dayKey(DateTime.parse(row['completedAt'])) == row['completedDate'],
      );
      require(completionKeys.add('$j:$r:${row['completedDate']}'));
    }
    for (final key in preferenceKeys) {
      require(prefs[key] == null || prefs[key] is String);
      if (prefs[key] != null) jsonDecode(prefs[key] as String);
    }
    if (prefs['custom_zikr'] != null) {
      final custom = jsonDecode(prefs['custom_zikr']) as List;
      final customNames = <String>{};
      for (final row in custom) {
        require(
          row is Map &&
              row['name'] is String &&
              (row['name'] as String).trim().isNotEmpty &&
              customNames.add(row['name']) &&
              row['arabic'] is String &&
              row['meaning'] is String,
        );
      }
    }
    if (prefs[RoutineService.key] != null) {
      final config = jsonDecode(prefs[RoutineService.key]) as Map;
      for (final key in ['dhikrGoal', 'rukuGoal']) {
        require(
          config[key] is int && config[key] >= 1 && config[key] <= 1000000,
        );
      }
      for (final key in ['dhikrMinute', 'quranMinute']) {
        require(config[key] is int && config[key] >= 0 && config[key] < 1440);
      }
      require(config['reminders'] is bool);
      if (config['finishDate'] != null) DateTime.parse(config['finishDate']);
    }
    if (prefs['adhkar_v1'] != null) {
      final counts = jsonDecode(prefs['adhkar_v1']) as Map;
      require(counts.values.every((v) => v is int && v >= 0 && v <= 1000000));
    }
    if (prefs[AdhkarService.collectionsKey] != null) {
      AdhkarService.decodeCollections(prefs[AdhkarService.collectionsKey]);
    }
    if (prefs[ReadingPreferences.key] != null)
      ReadingPreferences.decode(prefs[ReadingPreferences.key]);
  }

  static Future<void> restore(String content) async {
    final backup = jsonDecode(content) as Map<String, dynamic>;
    validate(backup); // Validate everything before changing stored data.
    final db = await DatabaseService().database;
    final prefs = await SharedPreferences.getInstance();
    final previous = {
      for (final key in preferenceKeys) key: prefs.getString(key),
    };
    Future<void> writePreferences(Map values) async {
      for (final key in preferenceKeys) {
        final value = values[key] as String?;
        final ok = value == null
            ? await prefs.remove(key)
            : await prefs.setString(key, value);
        if (!ok) throw StateError('Could not write preferences');
      }
    }

    try {
      await writePreferences(backup['preferences'] as Map);
      await db.transaction((txn) async {
        for (final table in tables.reversed) {
          await txn.delete(table);
        }
        final data = backup['tables'] as Map;
        for (final row in data['zikr_counters'] as List) {
          await txn.insert(
            'zikr_counters',
            ZikrCounter.fromMap(Map<String, dynamic>.from(row)).toMap(),
          );
        }
        for (final row in data['zikr_sessions'] as List) {
          await txn.insert(
            'zikr_sessions',
            ZikrSession.fromMap(Map<String, dynamic>.from(row)).toMap(),
          );
        }
        for (final row in data['quran_progress'] as List) {
          await txn.insert(
            'quran_progress',
            QuranProgress.fromMap(Map<String, dynamic>.from(row)).toMap(),
          );
        }
        for (final row in data['quran_completions'] as List) {
          await txn.insert('quran_completions', {
            for (final key in [
              'juzNumber',
              'rukuNumber',
              'completedDate',
              'completedAt',
            ])
              key: row[key],
          });
        }
      });
    } catch (_) {
      await writePreferences(previous);
      rethrow;
    }
    RoutineService.changes.value++;
    await ReadingPreferences.instance.load();
  }

  static Future<String> exportCsv() async {
    final backup = await snapshot();
    final data = backup['tables'] as Map;
    final rows = <List<dynamic>>[
      [
        'type',
        'name_or_location',
        'count',
        'lifetime_total',
        'target',
        'timestamp',
      ],
    ];
    String safe(String s) => RegExp(r'^[=+@\-\t\r]').hasMatch(s) ? "'$s" : s;
    final names = <int, String>{};
    for (final row in data['zikr_counters'] as List) {
      names[row['id']] = row['name'];
      rows.add([
        'counter',
        safe(row['name']),
        row['sessionCount'],
        row['lifetimeTotal'],
        row['target'],
        row['lastUpdated'],
      ]);
    }
    for (final row in data['zikr_sessions'] as List) {
      rows.add([
        'session',
        safe(names[row['zikrId']] ?? ''),
        row['count'],
        '',
        '',
        row['timestamp'],
      ]);
    }
    for (final row in data['quran_progress'] as List) {
      rows.add(['quran', safe(row['location']), '', '', '', row['timestamp']]);
    }
    for (final row in data['quran_completions'] as List) {
      rows.add([
        'quran_completed',
        'Juz ${row['juzNumber']}, Ruku ${row['rukuNumber']}',
        1,
        '',
        '',
        row['completedAt'],
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  static Future<void> resetProgress() async {
    final db = await DatabaseService().database;
    await db.transaction((txn) async {
      await txn.delete('zikr_sessions');
      await txn.delete('quran_progress');
      await txn.delete('quran_completions');
      await txn.update('zikr_counters', {
        'sessionCount': 0,
        'lifetimeTotal': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
        'lastResetDate': dayKey(DateTime.now()),
      });
    });
    await (await SharedPreferences.getInstance()).remove('adhkar_v1');
    RoutineService.changes.value++;
    await RoutineService.updateWidget();
  }
}
