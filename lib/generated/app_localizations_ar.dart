// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق ذكر والقرآن';

  @override
  String get home => 'الرئيسية';

  @override
  String get quran => 'القرآن';

  @override
  String get zikr => 'ذكر';

  @override
  String get settings => 'الإعدادات';

  @override
  String get selectQuran => 'اختر القرآن';

  @override
  String get selectZikr => 'اختر الذكر';

  @override
  String get chooseYourZikr => 'اختر ذكرك';

  @override
  String get selectTheZikr => 'اختر الذكر الذي تريد عده';

  @override
  String get startReading => 'ابدأ القراءة';

  @override
  String get continueReading => 'استمر في القراءة';

  @override
  String lastProgress(String location) {
    return 'آخر: $location';
  }

  @override
  String get startZikr => 'ابدأ الذكر';

  @override
  String get continueZikr => 'استمر في الذكر';

  @override
  String get startFirstZikr => 'ابدأ أول ذكر لك';

  @override
  String get todayZikr => 'ذكر اليوم';

  @override
  String get totalZikr => 'إجمالي الذكر';

  @override
  String get activeZikrs => 'الأذكار النشطة';

  @override
  String get total => 'المجموع';

  @override
  String get addZikr => 'أضف ذكر';

  @override
  String get addCustomZikr => 'أضف ذكر مخصص';

  @override
  String get nameRequired => '* الاسم مطلوب، والباقي اختياري';

  @override
  String get name => 'الاسم';

  @override
  String get nameLabel => 'الاسم *';

  @override
  String get arabicText => 'النص العربي';

  @override
  String get meaning => 'المعنى';

  @override
  String get cancel => 'إلغاء';

  @override
  String get add => 'إضافة';

  @override
  String get close => 'إغلاق';

  @override
  String get nameIsRequired => 'الاسم مطلوب';

  @override
  String get zikrAddedSuccessfully => 'تمت إضافة الذكر بنجاح!';

  @override
  String get zikrAlreadyExists => 'يوجد ذكر بهذا الاسم بالفعل';

  @override
  String get today => 'اليوم';

  @override
  String get tapToCount => 'اضغط للعد';

  @override
  String get history => 'السجل';

  @override
  String get lastSevenDays => 'آخر 7 أيام';

  @override
  String get loadingProgress => 'جاري تحميل تقدمك...';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get english => 'English (الإنجليزية)';

  @override
  String get arabic => 'العربية';

  @override
  String get urdu => 'اردو (الأردية)';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get subhanallah => 'سبحان الله';

  @override
  String get alhamdulillah => 'الحمد لله';

  @override
  String get allahuAkbar => 'الله أكبر';

  @override
  String get laIlahaIllallah => 'لا إله إلا الله';

  @override
  String get astaghfirullah => 'أستغفر الله';

  @override
  String get gloryBeToAllah => 'سبحان الله';

  @override
  String get allPraiseToAllah => 'كل الحمد لله';

  @override
  String get allahIsGreatest => 'الله أكبر';

  @override
  String get noDeityExceptAllah => 'لا إله إلا الله';

  @override
  String get iSeekForgiveness => 'أستغفر الله';

  @override
  String get customZikr => 'ذكر مخصص';

  @override
  String get times => 'مرات';

  @override
  String get selectJuz => 'اختر الجزء';

  @override
  String get chooseYourJuz => 'اختر جزءك';

  @override
  String get selectFrom30Juz => 'اختر من 30 جزءًا لبدء تتبع القرآن';

  @override
  String get selectRuku => 'اختر الركوع';

  @override
  String get chooseRuku => 'اختر الركوع';

  @override
  String get ruku => 'ركوع';

  @override
  String rukusInJuz(int count, int juzNumber) {
    return '$count ركوعات في الجزء $juzNumber';
  }

  @override
  String get todayCount => 'اليوم';

  @override
  String get totalCount => 'المجموع';

  @override
  String get customIncrement => 'مخصص';

  @override
  String get customIncrementDialog => 'زيادة مخصصة';

  @override
  String get enterNumber => 'أدخل الرقم';

  @override
  String get historyTitle => 'السجل';

  @override
  String get todayLabel => 'اليوم:';

  @override
  String get totalLabel => 'المجموع:';

  @override
  String get lastSevenDaysLabel => 'آخر 7 أيام';

  @override
  String get juz => 'جزء';
}
