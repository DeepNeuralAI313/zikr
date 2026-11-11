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

  @override
  String get currentSessionLabel => '?????? ????';

  @override
  String get previousSessionsLabel => '????? ??????';

  @override
  String get allTimeTotalLabel => '?? ?? ?? ??';

  @override
  String get noCompletedSessionsMessage =>
      '???? ???? ???? ???? ???? ????? ?????? ???? ?? ?? ?? ??? ???? ??? ???? ???';

  @override
  String get dailyRoutine => 'روزانہ کا معمول';

  @override
  String get todaysRoutine => 'آج کا معمول';

  @override
  String get personalGoals => 'آپ کے ذاتی اہداف';

  @override
  String get dailyDhikrGoal => 'روزانہ ذکر کا ہدف';

  @override
  String get dailyRukuGoal => 'روزانہ رکوع کا ہدف';

  @override
  String get validGoals => '۱ سے ۱۰۰۰۰۰۰ تک صحیح عدد درج کریں۔';

  @override
  String get quranPlanner => 'ختم قرآن کا منصوبہ';

  @override
  String get plannerExplanation =>
      'ہدف پڑھے ہوئے نشان زد رکوع کی بنیاد پر ہے۔ صرف جگہ محفوظ کرنے سے تلاوت مکمل شمار نہیں ہوتی۔';

  @override
  String get finishDate => 'تکمیل کی تاریخ';

  @override
  String get chooseDate => 'تاریخ منتخب کریں';

  @override
  String get remainingRukus => 'باقی رکوع';

  @override
  String get rukusPerDay => 'روزانہ رکوع';

  @override
  String get planExpired => 'مقررہ تاریخ گزر چکی ہے۔ نئی تاریخ منتخب کریں۔';

  @override
  String get useTarget => 'یہ روزانہ ہدف استعمال کریں';

  @override
  String get dailyReminders => 'روزانہ یاد دہانیاں';

  @override
  String get reminderExplanation =>
      'مقامی اوقات منتخب کریں۔ فون کی بیٹری سیٹنگز سے تاخیر ہو سکتی ہے۔';

  @override
  String get mobileRemindersOnly =>
      'یاد دہانیاں Android اور iOS پر دستیاب ہیں۔';

  @override
  String get dhikrReminder => 'ذکر کی یاد دہانی';

  @override
  String get quranReminder => 'قرآن کی یاد دہانی';

  @override
  String get saveRoutine => 'معمول محفوظ کریں';

  @override
  String get saving => 'محفوظ ہو رہا ہے…';

  @override
  String get routineSaved => 'آپ کا معمول محفوظ ہو گیا۔';

  @override
  String get notificationDenied =>
      'اطلاعات بند ہیں۔ فون کی سیٹنگز میں اجازت دے کر یاد دہانیاں دوبارہ فعال کریں۔';

  @override
  String get saveFailed => 'محفوظ نہیں ہو سکا';

  @override
  String get progressLoadFailed =>
      'پیش رفت لوڈ نہیں ہو سکی۔ دوبارہ کوشش کے لیے صفحہ کھولیں۔';

  @override
  String get recordedRukusExplanation =>
      'آج پڑھے ہوئے نشان زد رکوع۔ جگہ محفوظ کرنے سے تلاوت کی گنتی نہیں بڑھتی۔';

  @override
  String get routineComplete => 'الحمدللہ، آج کے اہداف مکمل ہو گئے۔';

  @override
  String get guidedAdhkar => 'صبح و شام کے اذکار';

  @override
  String get morningAdhkar => 'صبح';

  @override
  String get eveningAdhkar => 'شام';

  @override
  String get adhkarExplanation =>
      'مختصر مجموعہ۔ صبح و شام کی گنتی ہر روز الگ محفوظ ہوتی ہے اور مرکزی ذکر کاؤنٹر سے الگ ہے۔ معانی انگریزی میں ہیں۔';

  @override
  String get completed => 'مکمل';

  @override
  String get goalsAndReminders =>
      'اہداف، تلاوت کا منصوبہ اور یاد دہانی کے اوقات';

  @override
  String get createBackup => 'بیک اپ فائل محفوظ کریں';

  @override
  String get backupExplanation =>
      'گنتی، تاریخ، ذاتی اذکار، معمول اور رہنمائی والے اذکار شامل ہیں۔ نقل محفوظ جگہ رکھیں۔';

  @override
  String get shareBackup => 'بیک اپ شیئر کریں';

  @override
  String get restoreBackup => 'بیک اپ بحال کریں';

  @override
  String get exportCsv => 'پیش رفت CSV میں برآمد کریں';

  @override
  String get fileSaved => 'فائل محفوظ ہو گئی۔';

  @override
  String get confirmAction => 'جاری رکھیں';

  @override
  String get backupTooLarge => '۲۵ ایم بی سے چھوٹا بیک اپ منتخب کریں۔';

  @override
  String get restoreWarning =>
      'یہ موجودہ گنتی، تاریخ، ذاتی اذکار، معمول اور رہنمائی والے اذکار کو بیک اپ سے بدل دے گا۔ پہلے موجودہ ڈیٹا کا بیک اپ محفوظ کریں۔';

  @override
  String get backupRestored => 'بیک اپ بحال ہو گیا۔';

  @override
  String get reminderRestoreFailed =>
      'ڈیٹا بحال ہو گیا۔ یاد دہانیاں دوبارہ ترتیب دینے کے لیے روزانہ معمول کھولیں۔';

  @override
  String get resetProgress => 'تمام پیش رفت ری سیٹ کریں';

  @override
  String get resetWarning =>
      'یہ ذکر کی گنتی، نشستوں کی تاریخ، قرآن کی پیش رفت اور رہنمائی والے اذکار کی گنتی مٹا دے گا۔ ذاتی اذکار اور معمول برقرار رہیں گے۔ پہلے بیک اپ بنائیں۔ واپسی ممکن نہیں۔';

  @override
  String get progressReset => 'پیش رفت ری سیٹ ہو گئی۔';

  @override
  String get homeWidget => 'Android ہوم اسکرین ویجٹ';

  @override
  String get widgetInstructions =>
      'Android پر ہوم اسکرین کو دیر تک دبائیں، Widgets میں Dhikr منتخب کریں۔ کاؤنٹر کھولنے کے لیے ویجٹ دبائیں۔';

  @override
  String get localPrivacy => 'آپ کا ڈیٹا آپ کے فون پر رہتا ہے';

  @override
  String get privacyExplanation =>
      'اکاؤنٹ یا کلاؤڈ سنک ضروری نہیں۔ بیک اپ میں آپ کی پیش رفت ہوتی ہے؛ محفوظ یا شیئر کرنے کی جگہ آپ منتخب کرتے ہیں۔';

  @override
  String get appVersion => 'ایپ ورژن';

  @override
  String get csvExplanation =>
      'پیش رفت کی اسپریڈشیٹ محفوظ کریں۔ یہ فائل دیکھنے کے لیے ہے، بحالی کے لیے نہیں۔';

  @override
  String get shareBackupExplanation =>
      'کسی دوسری ایپ سے JSON بیک اپ شیئر کریں۔';

  @override
  String get restoreBackupExplanation =>
      'بحالی کے لیے JSON بیک اپ فائل منتخب کریں۔';

  @override
  String get adhkarCollectionsExplanation =>
      'صبح و شام کی فہرستیں الگ ہیں۔ ہر فہرست میں الگ اضافہ، ترمیم یا حذف کریں۔ ظاہری ترتیب میں متن کا سائز، رومن تلفظ اور معنی کی زبان منتخب کریں۔';

  @override
  String get emptyAdhkarCollection =>
      'یہ فہرست خالی ہے۔ اوپر سے اپنا پہلا ذکر شامل کریں۔';

  @override
  String get editDhikr => 'ذکر میں ترمیم';

  @override
  String get deleteDhikr => 'ذکر حذف کریں';

  @override
  String get deleteGuidedWarning =>
      'یہ ذکر اس فہرست سے حذف کریں؟ دوسری فہرست اور اس کی گنتی برقرار رہے گی۔';

  @override
  String get addToCollection => 'اس میں شامل کریں';

  @override
  String get bothCollections => 'صبح اور شام';

  @override
  String get sourceOptional => 'حوالہ (اختیاری)';

  @override
  String get repetitionTarget => 'تکرار کی تعداد';

  @override
  String get saveDhikr => 'ذکر محفوظ کریں';

  @override
  String get appearance => 'ظاہری ترتیب';

  @override
  String get appearanceSummary => 'زبان، تھیم اور پڑھنے کی ترتیبات';

  @override
  String get yourData => 'آپ کا ڈیٹا';

  @override
  String get yourDataSummary => 'پیش رفت کا بیک اپ، بحالی یا برآمد';

  @override
  String get arabicTextSize => 'عربی متن کا سائز';

  @override
  String get meaningTextSize => 'معنی کے متن کا سائز';

  @override
  String get showTransliteration => 'رومن تلفظ دکھائیں';

  @override
  String get meaningLanguage => 'معنی کی زبان';

  @override
  String get followAppLanguage => 'ایپ کی زبان کے مطابق';

  @override
  String get meaningFallbackExplanation =>
      'پہلے سے موجود اذکار کے اردو معانی دستیاب ہیں۔ دوسرے اذکار میں محفوظ شدہ معنی دکھائے جاتے ہیں۔';

  @override
  String get readingPreview => 'متن کی جھلک';

  @override
  String get transliterationOptional => 'رومن تلفظ (اختیاری)';

  @override
  String get urduMeaningOptional => 'اردو معنی (اختیاری)';

  @override
  String get saveMyPlace => 'میری جگہ محفوظ کریں';

  @override
  String get bookmarkOnlyExplanation =>
      'دوبارہ شروع کرنے کی جگہ محفوظ کریں۔ اس سے رکوع پڑھا ہوا شمار نہیں ہوگا۔';

  @override
  String get markAsRead => 'پڑھا ہوا نشان لگائیں';

  @override
  String get completionExplanation =>
      'اس رکوع کو آج مکمل شمار کریں اور محفوظ جگہ تازہ کریں۔';

  @override
  String get undoCompletion => 'آج کی تکمیل واپس لیں';

  @override
  String get undoCompletionExplanation =>
      'یہ رکوع آج کی مکمل تلاوت سے ہٹائیں۔ محفوظ جگہ برقرار رہے گی۔';

  @override
  String get bookmarkSaved => 'تلاوت کی جگہ محفوظ ہو گئی۔';

  @override
  String get readingRecorded => 'رکوع آج کے لیے پڑھا ہوا نشان زد ہو گیا۔';

  @override
  String get completionRemoved => 'آج کی تکمیل واپس لے لی گئی۔';

  @override
  String get quranTrackingExplanation =>
      'جگہ محفوظ کرنے یا پڑھا ہوا نشان لگانے کے لیے رکوع دبائیں۔ نشان آج کی مکمل تلاوت دکھاتے ہیں۔';
}
