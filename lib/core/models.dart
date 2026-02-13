// Data models for the app

// Quran Progress Model - tracks Juz, Ruku, and Ayah progress
class QuranProgress {
  final int? id;
  final int juzNumber;
  final int rukuNumber;
  final int? ayahNumber;
  final String location; // e.g., "Juz 2, Ruku 5, Ayah 45"
  final DateTime timestamp;
  
  QuranProgress({
    this.id,
    required this.juzNumber,
    required this.rukuNumber,
    this.ayahNumber,
    required this.location,
    required this.timestamp,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'juzNumber': juzNumber,
      'rukuNumber': rukuNumber,
      'ayahNumber': ayahNumber,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory QuranProgress.fromMap(Map<String, dynamic> map) {
    return QuranProgress(
      id: map['id'],
      juzNumber: map['juzNumber'],
      rukuNumber: map['rukuNumber'],
      ayahNumber: map['ayahNumber'],
      location: map['location'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
  
  String get displayLocation {
    if (ayahNumber != null) {
      return "Juz $juzNumber, Ruku $rukuNumber, Ayah $ayahNumber";
    } else {
      return "Juz $juzNumber, Ruku $rukuNumber";
    }
  }
  
  String get shortLocation {
    if (ayahNumber != null) {
      return "J$juzNumber R$rukuNumber A$ayahNumber";
    } else {
      return "J$juzNumber R$rukuNumber";
    }
  }
}

// Zikr Counter Model
class ZikrCounter {
  final int id;
  final String name;
  final String arabic;
  final String meaning;
  final int sessionCount;  // Current session count (resets daily automatically)
  final int lifetimeTotal; // All-time total (never resets)
  final int target;
  final DateTime lastUpdated;
  final String? lastResetDate; // Date of last daily reset (YYYY-MM-DD)
  
  ZikrCounter({
    required this.id,
    required this.name,
    required this.arabic,
    required this.meaning,
    required this.sessionCount,
    required this.lifetimeTotal,
    required this.target,
    required this.lastUpdated,
    this.lastResetDate,
  });
  
  double get progress => target == 0 ? 0.0 : (sessionCount / target).clamp(0.0, 1.0);
  bool get isCompleted => sessionCount >= target;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'meaning': meaning,
      'sessionCount': sessionCount,
      'lifetimeTotal': lifetimeTotal,
      'target': target,
      'lastUpdated': lastUpdated.toIso8601String(),
      'lastResetDate': lastResetDate,
    };
  }
  
  factory ZikrCounter.fromMap(Map<String, dynamic> map) {
    return ZikrCounter(
      id: map['id'],
      name: map['name'],
      arabic: map['arabic'],
      meaning: map['meaning'] ?? '',
      sessionCount: map['sessionCount'] ?? map['count'] ?? 0, // Backward compatibility
      lifetimeTotal: map['lifetimeTotal'] ?? map['count'] ?? 0, // Backward compatibility
      target: map['target'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
      lastResetDate: map['lastResetDate'],
    );
  }
  
  ZikrCounter copyWith({
    int? sessionCount,
    int? lifetimeTotal,
    int? target,
    DateTime? lastUpdated,
    String? lastResetDate,
  }) {
    return ZikrCounter(
      id: id,
      name: name,
      arabic: arabic,
      meaning: meaning,
      sessionCount: sessionCount ?? this.sessionCount,
      lifetimeTotal: lifetimeTotal ?? this.lifetimeTotal,
      target: target ?? this.target,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }
}

// Zikr Session Model - Records individual completed sessions
class ZikrSession {
  final int? id;
  final int zikrId;
  final int count;
  final DateTime timestamp;
  
  ZikrSession({
    this.id,
    required this.zikrId,
    required this.count,
    required this.timestamp,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zikrId': zikrId,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory ZikrSession.fromMap(Map<String, dynamic> map) {
    return ZikrSession(
      id: map['id'],
      zikrId: map['zikrId'],
      count: map['count'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
  
  String get dateOnly => timestamp.toIso8601String().split('T')[0];
}

// Keep ZikrHistory as alias for backward compatibility
typedef ZikrHistory = ZikrSession;