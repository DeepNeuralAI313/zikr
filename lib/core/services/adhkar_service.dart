import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarEntry {
  final String id,
      title,
      arabic,
      translation,
      reference,
      transliteration,
      urduMeaning;
  final int repetitions;
  const AdhkarEntry(
    this.title,
    this.arabic,
    this.translation,
    this.reference,
    this.repetitions, {
    this.id = '',
    this.transliteration = '',
    this.urduMeaning = '',
  });
  AdhkarEntry withId(String value) => AdhkarEntry(
    title,
    arabic,
    translation,
    reference,
    repetitions,
    id: value,
    transliteration: transliteration,
    urduMeaning: urduMeaning,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'arabic': arabic,
    'translation': translation,
    'reference': reference,
    'repetitions': repetitions,
    'transliteration': transliteration,
    'urduMeaning': urduMeaning,
  };
  factory AdhkarEntry.fromJson(Map<String, dynamic> data) {
    final entry = AdhkarEntry(
      data['title'] as String,
      data['arabic'] as String,
      data['translation'] as String,
      data['reference'] as String,
      data['repetitions'] as int,
      id: data['id'] as String,
      transliteration: data['transliteration'] as String? ?? '',
      urduMeaning: data['urduMeaning'] as String? ?? '',
    );
    if (!RegExp(r'^[a-zA-Z0-9_-]{1,100}$').hasMatch(entry.id) ||
        entry.title.trim().isEmpty ||
        entry.title.length > 200 ||
        entry.arabic.length > 10000 ||
        entry.translation.length > 10000 ||
        entry.reference.length > 1000 ||
        entry.transliteration.length > 10000 ||
        entry.urduMeaning.length > 10000 ||
        entry.repetitions < 1 ||
        entry.repetitions > 1000000) {
      throw const FormatException('Invalid guided dhikr');
    }
    return entry;
  }
}

class AdhkarService {
  static const collectionsKey = 'adhkar_collections_v1';
  static const countsKey = 'adhkar_v1';

  static Map<String, List<AdhkarEntry>> decodeCollections(String encoded) {
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    final result = <String, List<AdhkarEntry>>{};
    for (final lane in ['morning', 'evening']) {
      final rows = data[lane] as List;
      if (rows.length > 1000) {
        throw const FormatException('Too many guided adhkar');
      }
      final entries = rows.map((row) {
        final data = Map<String, dynamic>.from(row);
        final entry = AdhkarEntry.fromJson(data);
        // Enrich only unchanged legacy built-ins, never a user's edited text.
        if (!data.containsKey('transliteration') &&
            !data.containsKey('urduMeaning')) {
          for (final original in defaults(lane)) {
            if (entry.id == original.id &&
                entry.arabic == original.arabic &&
                entry.translation == original.translation &&
                entry.reference == original.reference) {
              return AdhkarEntry(
                entry.title,
                entry.arabic,
                entry.translation,
                entry.reference,
                entry.repetitions,
                id: entry.id,
                transliteration: original.transliteration,
                urduMeaning: original.urduMeaning,
              );
            }
          }
        }
        return entry;
      }).toList();
      final ids = <String>{};
      final names = <String>{};
      for (final entry in entries) {
        if (!ids.add(entry.id) ||
            !names.add(entry.title.trim().toLowerCase())) {
          throw const FormatException('Duplicate guided dhikr');
        }
      }
      result[lane] = entries;
    }
    return result;
  }

  static Future<Map<String, List<AdhkarEntry>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(collectionsKey);
    return encoded == null
        ? {'morning': defaults('morning'), 'evening': defaults('evening')}
        : decodeCollections(encoded);
  }

  static Future<void> save(Map<String, List<AdhkarEntry>> collections) async {
    final encoded = jsonEncode({
      for (final lane in ['morning', 'evening'])
        lane: collections[lane]!.map((entry) => entry.toJson()).toList(),
    });
    decodeCollections(encoded);
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(collectionsKey, encoded)) {
      throw StateError('Could not save guided adhkar');
    }
  }

  static List<AdhkarEntry> defaults(String lane) => [
    // Preserve the old numeric IDs so existing progress survives the update.
    for (final pair in adhkarEntries.indexed) pair.$2.withId('${pair.$1}'),
    if (lane == 'morning')
      const AdhkarEntry(
        'Morning dua',
        'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
        'O Allah, You bring us into the morning and evening; our life and death are in Your hands, and to You we will rise again.',
        'Sunan Abi Dawud 5068\nhttps://sunnah.com/abudawud:5068',
        1,
        id: 'morning_dua',
        transliteration:
            'Allahumma bika asbahna, wa bika amsayna, wa bika nahya, wa bika namutu, wa ilaykan-nushur.',
        urduMeaning:
            'اے اللہ! تیرے ہی فضل سے ہم نے صبح کی اور شام کی، تیرے ہی حکم سے ہم جیتے اور مرتے ہیں، اور تیری ہی طرف دوبارہ اٹھ کر جانا ہے۔',
      ),
    if (lane == 'evening')
      const AdhkarEntry(
        'Evening dua',
        'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
        'O Allah, You bring us into the evening and morning; our life and death are in Your hands, and to You we return.',
        'Sunan Ibn Majah 3868\nhttps://sunnah.com/ibnmajah:3868',
        1,
        id: 'evening_dua',
        transliteration:
            'Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika namutu, wa ilaykal-masir.',
        urduMeaning:
            'اے اللہ! تیرے ہی فضل سے ہم نے شام کی اور صبح کی، تیرے ہی حکم سے ہم جیتے اور مرتے ہیں، اور تیری ہی طرف لوٹنا ہے۔',
      ),
  ];
}

// Quran text and concise renderings of its meaning. Repetition references below.
const adhkarEntries = [
  AdhkarEntry(
    'Al-Ikhlas (112)',
    'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
    'Say: He is Allah, One. Allah, the One all depend upon. He neither begets nor was born. And none is comparable to Him.',
    'Quran 112:1–4 • Sunan Abi Dawud 5082\nhttps://sunnah.com/abudawud:5082',
    3,
    transliteration:
        'Qul huwa Allahu ahad. Allahus-samad. Lam yalid wa lam yulad. Wa lam yakun lahu kufuwan ahad.',
    urduMeaning:
        'کہہ دو: وہ اللہ ایک ہے۔ اللہ بے نیاز ہے۔ نہ اس کی کوئی اولاد ہے اور نہ وہ کسی کی اولاد ہے۔ اور کوئی اس کے برابر نہیں۔',
  ),
  AdhkarEntry(
    'Al-Falaq (113)',
    'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    'Say: I seek refuge in the Lord of daybreak, from the evil of what He created, from the evil of darkness as it falls, from the evil of those who blow upon knots, and from the evil of an envier when he envies.',
    'Quran 113:1–5 • Sunan Abi Dawud 5082\nhttps://sunnah.com/abudawud:5082',
    3,
    transliteration:
        "Qul a’udhu bi Rabbil-falaq. Min sharri ma khalaq. Wa min sharri ghasiqin idha waqab. Wa min sharrin-naffathati fil-’uqad. Wa min sharri hasidin idha hasad.",
    urduMeaning:
        'کہہ دو: میں صبح کے رب کی پناہ مانگتا ہوں، اس کی پیدا کی ہوئی چیزوں کے شر سے، اندھیری رات کے شر سے جب وہ چھا جائے، گرہوں میں پھونکنے والیوں کے شر سے، اور حسد کرنے والے کے شر سے جب وہ حسد کرے۔',
  ),
  AdhkarEntry(
    'An-Nas (114)',
    'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    'Say: I seek refuge in the Lord of people, the King of people, the God of people, from the evil of the retreating whisperer, who whispers into the hearts of people, from among jinn and people.',
    'Quran 114:1–6 • Sunan Abi Dawud 5082\nhttps://sunnah.com/abudawud:5082',
    3,
    transliteration:
        "Qul a’udhu bi Rabbin-nas. Malikin-nas. Ilahin-nas. Min sharril-waswasil-khannas. Alladhi yuwaswisu fi sudurin-nas. Minal-jinnati wan-nas.",
    urduMeaning:
        'کہہ دو: میں لوگوں کے رب، لوگوں کے بادشاہ، لوگوں کے معبود کی پناہ مانگتا ہوں، چھپ چھپ کر وسوسہ ڈالنے والے کے شر سے، جو لوگوں کے دلوں میں وسوسے ڈالتا ہے، خواہ وہ جنوں میں سے ہو یا انسانوں میں سے۔',
  ),
  AdhkarEntry(
    'SubhanAllahi wa bihamdihi',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    'Glory and praise belong to Allah.',
    'Sahih Muslim 2692\nhttps://sunnah.com/muslim:2692',
    100,
    transliteration: 'SubhanAllahi wa bihamdihi.',
    urduMeaning: 'اللہ پاک ہے اور تمام تعریف اسی کے لیے ہے۔',
  ),
];
