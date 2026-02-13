// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dhikr Quran Tracker';

  @override
  String get home => 'Home';

  @override
  String get quran => 'Quran';

  @override
  String get zikr => 'Dhikr';

  @override
  String get settings => 'Settings';

  @override
  String get selectQuran => 'Select a Quran';

  @override
  String get selectZikr => 'Select a Dhikr';

  @override
  String get chooseYourZikr => 'Choose your Dhikr';

  @override
  String get selectTheZikr => 'Select the Dhikr you want to count';

  @override
  String get startReading => 'Start Reading';

  @override
  String get continueReading => 'Continue Reading';

  @override
  String lastProgress(String location) {
    return 'Last: $location';
  }

  @override
  String get startZikr => 'Start Dhikr';

  @override
  String get continueZikr => 'Continue Dhikr';

  @override
  String get startFirstZikr => 'Start your first Dhikr';

  @override
  String get todayZikr => 'Today\'s Dhikr';

  @override
  String get totalZikr => 'Total Dhikr';

  @override
  String get activeZikrs => 'Active Dhikrs';

  @override
  String get total => 'total';

  @override
  String get addZikr => 'Add Dhikr';

  @override
  String get addCustomZikr => 'Add Custom Dhikr';

  @override
  String get nameRequired => '* Name is required, others are optional';

  @override
  String get name => 'Name';

  @override
  String get nameLabel => 'Name *';

  @override
  String get arabicText => 'Arabic Text';

  @override
  String get meaning => 'Meaning';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get zikrAddedSuccessfully => 'Dhikr added successfully!';

  @override
  String get zikrAlreadyExists => 'A dhikr with this name already exists';

  @override
  String get today => 'Today';

  @override
  String get tapToCount => 'Tap to count';

  @override
  String get history => 'History';

  @override
  String get lastSevenDays => 'Last 7 Days';

  @override
  String get loadingProgress => 'Loading your progress...';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية (Arabic)';

  @override
  String get urdu => 'اردو (Urdu)';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get subhanallah => 'SubhanAllah';

  @override
  String get alhamdulillah => 'Alhamdulillah';

  @override
  String get allahuAkbar => 'Allahu Akbar';

  @override
  String get laIlahaIllallah => 'La ilaha illallah';

  @override
  String get astaghfirullah => 'Astaghfirullah';

  @override
  String get gloryBeToAllah => 'Glory be to Allah';

  @override
  String get allPraiseToAllah => 'All praise is due to Allah';

  @override
  String get allahIsGreatest => 'Allah is the Greatest';

  @override
  String get noDeityExceptAllah => 'There is no deity except Allah';

  @override
  String get iSeekForgiveness => 'I seek forgiveness from Allah';

  @override
  String get customZikr => 'Custom Dhikr';

  @override
  String get times => 'times';

  @override
  String get selectJuz => 'Select Juz';

  @override
  String get chooseYourJuz => 'Choose your Juz';

  @override
  String get selectFrom30Juz =>
      'Select from 30 Juz to begin your Quran tracking';

  @override
  String get selectRuku => 'Select Ruku';

  @override
  String get chooseRuku => 'Choose Ruku';

  @override
  String get ruku => 'Ruku';

  @override
  String rukusInJuz(int count, int juzNumber) {
    return '$count Rukus in Juz $juzNumber';
  }

  @override
  String get todayCount => 'Today';

  @override
  String get totalCount => 'Total';

  @override
  String get customIncrement => 'Custom';

  @override
  String get customIncrementDialog => 'Custom Increment';

  @override
  String get enterNumber => 'Enter number';

  @override
  String get historyTitle => 'History';

  @override
  String get todayLabel => 'Today:';

  @override
  String get totalLabel => 'Total:';

  @override
  String get lastSevenDaysLabel => 'Last 7 Days';

  @override
  String get juz => 'Juz';
}
