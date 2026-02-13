// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'ذکر اور قرآن ٹریکر';

  @override
  String get home => 'ہوم';

  @override
  String get quran => 'قرآن';

  @override
  String get zikr => 'ذکر';

  @override
  String get settings => 'ترتیبات';

  @override
  String get selectQuran => 'قرآن منتخب کریں';

  @override
  String get selectZikr => 'ذکر منتخب کریں';

  @override
  String get chooseYourZikr => 'اپنا ذکر منتخب کریں';

  @override
  String get selectTheZikr => 'وہ ذکر منتخب کریں جس کی گنتی کرنا چاہتے ہیں';

  @override
  String get startReading => 'پڑھنا شروع کریں';

  @override
  String get continueReading => 'پڑھنا جاری رکھیں';

  @override
  String lastProgress(String location) {
    return 'آخری: $location';
  }

  @override
  String get startZikr => 'ذکر شروع کریں';

  @override
  String get continueZikr => 'ذکر جاری رکھیں';

  @override
  String get startFirstZikr => 'اپنا پہلا ذکر شروع کریں';

  @override
  String get todayZikr => 'آج کا ذکر';

  @override
  String get totalZikr => 'کل ذکر';

  @override
  String get activeZikrs => 'فعال اذکار';

  @override
  String get total => 'کل';

  @override
  String get addZikr => 'ذکر شامل کریں';

  @override
  String get addCustomZikr => 'اپنا ذکر شامل کریں';

  @override
  String get nameRequired => '* نام ضروری ہے، باقی اختیاری ہیں';

  @override
  String get name => 'نام';

  @override
  String get nameLabel => 'نام *';

  @override
  String get arabicText => 'عربی متن';

  @override
  String get meaning => 'معنی';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get add => 'شامل کریں';

  @override
  String get close => 'بند کریں';

  @override
  String get nameIsRequired => 'نام ضروری ہے';

  @override
  String get zikrAddedSuccessfully => 'ذکر کامیابی سے شامل ہو گیا!';

  @override
  String get zikrAlreadyExists => 'اس نام کا ذکر پہلے سے موجود ہے';

  @override
  String get today => 'آج';

  @override
  String get tapToCount => 'گننے کے لیے ٹیپ کریں';

  @override
  String get history => 'تاریخ';

  @override
  String get lastSevenDays => 'آخری 7 دن';

  @override
  String get loadingProgress => 'آپ کی پیشرفت لوڈ ہو رہی ہے...';

  @override
  String get changeLanguage => 'زبان تبدیل کریں';

  @override
  String get english => 'English (انگریزی)';

  @override
  String get arabic => 'العربية (عربی)';

  @override
  String get urdu => 'اردو';

  @override
  String get lightMode => 'روشن موڈ';

  @override
  String get darkMode => 'تاریک موڈ';

  @override
  String get subhanallah => 'سبحان اللہ';

  @override
  String get alhamdulillah => 'الحمد للہ';

  @override
  String get allahuAkbar => 'اللہ اکبر';

  @override
  String get laIlahaIllallah => 'لا الہ الا اللہ';

  @override
  String get astaghfirullah => 'استغفر اللہ';

  @override
  String get gloryBeToAllah => 'اللہ کی تسبیح';

  @override
  String get allPraiseToAllah => 'تمام تعریفیں اللہ کے لیے';

  @override
  String get allahIsGreatest => 'اللہ سب سے بڑا ہے';

  @override
  String get noDeityExceptAllah => 'اللہ کے سوا کوئی معبود نہیں';

  @override
  String get iSeekForgiveness => 'میں اللہ سے بخشش مانگتا ہوں';

  @override
  String get customZikr => 'حسب ضرورت ذکر';

  @override
  String get times => 'بار';

  @override
  String get selectJuz => 'جز منتخب کریں';

  @override
  String get chooseYourJuz => 'اپنا جز منتخب کریں';

  @override
  String get selectFrom30Juz =>
      'قرآن ٹریکنگ شروع کرنے کے لیے 30 جز میں سے منتخب کریں';

  @override
  String get selectRuku => 'رکوع منتخب کریں';

  @override
  String get chooseRuku => 'رکوع منتخب کریں';

  @override
  String get ruku => 'رکوع';

  @override
  String rukusInJuz(int count, int juzNumber) {
    return 'جز $juzNumber میں $count رکوع';
  }

  @override
  String get todayCount => 'آج';

  @override
  String get totalCount => 'کل';

  @override
  String get customIncrement => 'حسب ضرورت';

  @override
  String get customIncrementDialog => 'حسب ضرورت اضافہ';

  @override
  String get enterNumber => 'نمبر درج کریں';

  @override
  String get historyTitle => 'تاریخ';

  @override
  String get todayLabel => 'آج:';

  @override
  String get totalLabel => 'کل:';

  @override
  String get lastSevenDaysLabel => 'آخری 7 دن';

  @override
  String get juz => 'جز';
}
