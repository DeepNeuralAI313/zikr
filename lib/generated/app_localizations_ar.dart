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

  @override
  String get currentSessionLabel => '?????? ???????';

  @override
  String get previousSessionsLabel => '??????? ???????';

  @override
  String get allTimeTotalLabel => '???????? ?????';

  @override
  String get noCompletedSessionsMessage =>
      '?? ???? ????? ?????? ???. ????? ?????? ????? ?? ?????? ????? ?????? ???????.';

  @override
  String get dailyRoutine => 'الورد اليومي';

  @override
  String get todaysRoutine => 'ورد اليوم';

  @override
  String get personalGoals => 'أهدافك الشخصية';

  @override
  String get dailyDhikrGoal => 'هدف الذكر اليومي';

  @override
  String get dailyRukuGoal => 'هدف الركوع اليومي';

  @override
  String get validGoals => 'أدخل أعدادًا صحيحة من 1 إلى 1000000.';

  @override
  String get quranPlanner => 'خطة ختم القرآن';

  @override
  String get plannerExplanation =>
      'يستخدم الهدف الركوعات التي حددتها كمقروءة. لا تُحسب المواضع المحفوظة قراءة مكتملة.';

  @override
  String get finishDate => 'تاريخ الختم';

  @override
  String get chooseDate => 'اختر تاريخًا';

  @override
  String get remainingRukus => 'الركوعات المتبقية';

  @override
  String get rukusPerDay => 'ركوعات في اليوم';

  @override
  String get planExpired => 'انتهى الموعد. اختر تاريخًا جديدًا.';

  @override
  String get useTarget => 'استخدم هذا الهدف اليومي';

  @override
  String get dailyReminders => 'التذكيرات اليومية';

  @override
  String get reminderExplanation =>
      'اختر الأوقات المحلية. قد تؤخر إعدادات البطارية وصول التذكير.';

  @override
  String get mobileRemindersOnly => 'التذكيرات متاحة على Android وiOS.';

  @override
  String get dhikrReminder => 'تذكير الذكر';

  @override
  String get quranReminder => 'تذكير القرآن';

  @override
  String get saveRoutine => 'حفظ الورد';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String get routineSaved => 'تم حفظ وردك.';

  @override
  String get notificationDenied =>
      'الإشعارات معطلة. فعّلها في إعدادات الهاتف ثم فعّل التذكيرات مجددًا.';

  @override
  String get saveFailed => 'تعذر الحفظ';

  @override
  String get progressLoadFailed =>
      'تعذر تحميل التقدم. أعد فتح الشاشة للمحاولة.';

  @override
  String get recordedRukusExplanation =>
      'الركوعات المحددة كمقروءة اليوم. حفظ الموضع لا يزيد رصيد القراءة.';

  @override
  String get routineComplete => 'الحمد لله، اكتملت أهداف اليوم.';

  @override
  String get guidedAdhkar => 'أذكار الصباح والمساء';

  @override
  String get morningAdhkar => 'الصباح';

  @override
  String get eveningAdhkar => 'المساء';

  @override
  String get adhkarExplanation =>
      'مجموعة مختصرة. تُحفظ أعداد الصباح والمساء منفصلة يوميًا عن عدادات الذكر الرئيسية. المعاني أدناه بالإنجليزية.';

  @override
  String get completed => 'مكتمل';

  @override
  String get goalsAndReminders => 'الأهداف وخطة القراءة وأوقات التذكير';

  @override
  String get createBackup => 'حفظ ملف النسخة الاحتياطية';

  @override
  String get backupExplanation =>
      'يشمل العدادات والسجل والأذكار المخصصة والورد والأذكار الموجهة. احتفظ بنسخة آمنة.';

  @override
  String get shareBackup => 'مشاركة النسخة الاحتياطية';

  @override
  String get restoreBackup => 'استعادة نسخة احتياطية';

  @override
  String get exportCsv => 'تصدير التقدم بصيغة CSV';

  @override
  String get fileSaved => 'تم حفظ الملف.';

  @override
  String get confirmAction => 'متابعة';

  @override
  String get backupTooLarge => 'اختر نسخة أصغر من 25 ميغابايت.';

  @override
  String get restoreWarning =>
      'سيستبدل هذا العدادات والسجل والأذكار المخصصة والورد والأذكار الموجهة الحالية بالنسخة الاحتياطية. احفظ نسخة من بياناتك أولًا.';

  @override
  String get backupRestored => 'تمت استعادة النسخة الاحتياطية.';

  @override
  String get reminderRestoreFailed =>
      'تمت استعادة البيانات. افتح الورد اليومي لإعداد التذكيرات مجددًا.';

  @override
  String get resetProgress => 'تصفير كل التقدم';

  @override
  String get resetWarning =>
      'سيحذف هذا عدادات الذكر وسجل الجلسات وتقدم القرآن وأعداد الأذكار الموجهة. تبقى الأذكار المخصصة وإعدادات الورد. احفظ نسخة أولًا. لا يمكن التراجع.';

  @override
  String get progressReset => 'تم تصفير التقدم.';

  @override
  String get homeWidget => 'أداة الشاشة الرئيسية على Android';

  @override
  String get widgetInstructions =>
      'على Android اضغط مطولًا على الشاشة الرئيسية، ثم اختر الأدوات ثم Dhikr. اضغط الأداة لفتح العدادات.';

  @override
  String get localPrivacy => 'بياناتك تبقى على جهازك';

  @override
  String get privacyExplanation =>
      'لا يلزم حساب أو مزامنة سحابية. تحتوي النسخ على تقدمك، وأنت تختار مكان حفظها أو مشاركتها.';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get csvExplanation =>
      'احفظ جدولًا لتقدمك. هذا الملف للعرض وليس للاستعادة.';

  @override
  String get shareBackupExplanation =>
      'شارك نسخة احتياطية بصيغة JSON عبر تطبيق آخر.';

  @override
  String get restoreBackupExplanation =>
      'اختر ملف نسخة احتياطية بصيغة JSON لاستعادته.';

  @override
  String get adhkarCollectionsExplanation =>
      'قائمتا الصباح والمساء مستقلتان. أضف وعدّل واحذف لكل قائمة. اختر حجم النص والنطق ولغة المعنى من المظهر.';

  @override
  String get emptyAdhkarCollection =>
      'هذه القائمة فارغة. أضف أول ذكر من الأعلى.';

  @override
  String get editDhikr => 'تعديل الذكر';

  @override
  String get deleteDhikr => 'حذف الذكر';

  @override
  String get deleteGuidedWarning =>
      'هل تريد حذف هذا الذكر من هذه القائمة؟ ستبقى القائمة الأخرى وعداداتها.';

  @override
  String get addToCollection => 'أضف إلى';

  @override
  String get bothCollections => 'الصباح والمساء';

  @override
  String get sourceOptional => 'المصدر (اختياري)';

  @override
  String get repetitionTarget => 'عدد التكرارات';

  @override
  String get saveDhikr => 'حفظ الذكر';

  @override
  String get appearance => 'المظهر';

  @override
  String get appearanceSummary => 'اللغة والمظهر وإعدادات القراءة';

  @override
  String get yourData => 'بياناتك';

  @override
  String get yourDataSummary => 'نسخ تقدمك احتياطيًا أو استعادته أو تصديره';

  @override
  String get arabicTextSize => 'حجم النص العربي';

  @override
  String get meaningTextSize => 'حجم نص المعنى';

  @override
  String get showTransliteration => 'إظهار النطق بالحروف اللاتينية';

  @override
  String get meaningLanguage => 'لغة المعنى';

  @override
  String get followAppLanguage => 'حسب لغة التطبيق';

  @override
  String get meaningFallbackExplanation =>
      'المعاني بالأردية متاحة للأذكار الأصلية. تستخدم الأذكار الأخرى المعنى المحفوظ لها.';

  @override
  String get readingPreview => 'معاينة القراءة';

  @override
  String get transliterationOptional => 'النطق اللاتيني (اختياري)';

  @override
  String get urduMeaningOptional => 'المعنى بالأردية (اختياري)';

  @override
  String get saveMyPlace => 'حفظ موضعي';

  @override
  String get bookmarkOnlyExplanation =>
      'احفظ موضع المتابعة. لا يُحسب هذا الركوع مقروءًا.';

  @override
  String get markAsRead => 'تحديد كمقروء';

  @override
  String get completionExplanation =>
      'سجّل هذا الركوع مكتملًا اليوم وحدّث موضعك المحفوظ.';

  @override
  String get undoCompletion => 'إلغاء إكمال اليوم';

  @override
  String get undoCompletionExplanation =>
      'أزل هذا الركوع من قراءة اليوم المكتملة. يبقى موضعك المحفوظ.';

  @override
  String get bookmarkSaved => 'تم حفظ موضع القراءة.';

  @override
  String get readingRecorded => 'تم تسجيل الركوع مقروءًا اليوم.';

  @override
  String get completionRemoved => 'تم إلغاء إكمال اليوم.';

  @override
  String get quranTrackingExplanation =>
      'اضغط ركوعًا لحفظ موضعك أو تحديده كمقروء. تشير العلامات إلى ما أكملته اليوم.';
}
