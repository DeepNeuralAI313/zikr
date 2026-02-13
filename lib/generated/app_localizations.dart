import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ur'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Dhikr Quran Tracker'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @zikr.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get zikr;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @selectQuran.
  ///
  /// In en, this message translates to:
  /// **'Select a Quran'**
  String get selectQuran;

  /// No description provided for @selectZikr.
  ///
  /// In en, this message translates to:
  /// **'Select a Dhikr'**
  String get selectZikr;

  /// No description provided for @chooseYourZikr.
  ///
  /// In en, this message translates to:
  /// **'Choose your Dhikr'**
  String get chooseYourZikr;

  /// No description provided for @selectTheZikr.
  ///
  /// In en, this message translates to:
  /// **'Select the Dhikr you want to count'**
  String get selectTheZikr;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start Reading'**
  String get startReading;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// Last reading progress
  ///
  /// In en, this message translates to:
  /// **'Last: {location}'**
  String lastProgress(String location);

  /// No description provided for @startZikr.
  ///
  /// In en, this message translates to:
  /// **'Start Dhikr'**
  String get startZikr;

  /// No description provided for @continueZikr.
  ///
  /// In en, this message translates to:
  /// **'Continue Dhikr'**
  String get continueZikr;

  /// No description provided for @startFirstZikr.
  ///
  /// In en, this message translates to:
  /// **'Start your first Dhikr'**
  String get startFirstZikr;

  /// No description provided for @todayZikr.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Dhikr'**
  String get todayZikr;

  /// No description provided for @totalZikr.
  ///
  /// In en, this message translates to:
  /// **'Total Dhikr'**
  String get totalZikr;

  /// No description provided for @activeZikrs.
  ///
  /// In en, this message translates to:
  /// **'Active Dhikrs'**
  String get activeZikrs;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// No description provided for @addZikr.
  ///
  /// In en, this message translates to:
  /// **'Add Dhikr'**
  String get addZikr;

  /// No description provided for @addCustomZikr.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Dhikr'**
  String get addCustomZikr;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'* Name is required, others are optional'**
  String get nameRequired;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameLabel;

  /// No description provided for @arabicText.
  ///
  /// In en, this message translates to:
  /// **'Arabic Text'**
  String get arabicText;

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @zikrAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Dhikr added successfully!'**
  String get zikrAddedSuccessfully;

  /// No description provided for @zikrAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A dhikr with this name already exists'**
  String get zikrAlreadyExists;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get tapToCount;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get lastSevenDays;

  /// No description provided for @loadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading your progress...'**
  String get loadingProgress;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية (Arabic)'**
  String get arabic;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'اردو (Urdu)'**
  String get urdu;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @subhanallah.
  ///
  /// In en, this message translates to:
  /// **'SubhanAllah'**
  String get subhanallah;

  /// No description provided for @alhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get alhamdulillah;

  /// No description provided for @allahuAkbar.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get allahuAkbar;

  /// No description provided for @laIlahaIllallah.
  ///
  /// In en, this message translates to:
  /// **'La ilaha illallah'**
  String get laIlahaIllallah;

  /// No description provided for @astaghfirullah.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get astaghfirullah;

  /// No description provided for @gloryBeToAllah.
  ///
  /// In en, this message translates to:
  /// **'Glory be to Allah'**
  String get gloryBeToAllah;

  /// No description provided for @allPraiseToAllah.
  ///
  /// In en, this message translates to:
  /// **'All praise is due to Allah'**
  String get allPraiseToAllah;

  /// No description provided for @allahIsGreatest.
  ///
  /// In en, this message translates to:
  /// **'Allah is the Greatest'**
  String get allahIsGreatest;

  /// No description provided for @noDeityExceptAllah.
  ///
  /// In en, this message translates to:
  /// **'There is no deity except Allah'**
  String get noDeityExceptAllah;

  /// No description provided for @iSeekForgiveness.
  ///
  /// In en, this message translates to:
  /// **'I seek forgiveness from Allah'**
  String get iSeekForgiveness;

  /// No description provided for @customZikr.
  ///
  /// In en, this message translates to:
  /// **'Custom Dhikr'**
  String get customZikr;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @selectJuz.
  ///
  /// In en, this message translates to:
  /// **'Select Juz'**
  String get selectJuz;

  /// No description provided for @chooseYourJuz.
  ///
  /// In en, this message translates to:
  /// **'Choose your Juz'**
  String get chooseYourJuz;

  /// No description provided for @selectFrom30Juz.
  ///
  /// In en, this message translates to:
  /// **'Select from 30 Juz to begin your Quran tracking'**
  String get selectFrom30Juz;

  /// No description provided for @selectRuku.
  ///
  /// In en, this message translates to:
  /// **'Select Ruku'**
  String get selectRuku;

  /// No description provided for @chooseRuku.
  ///
  /// In en, this message translates to:
  /// **'Choose Ruku'**
  String get chooseRuku;

  /// No description provided for @ruku.
  ///
  /// In en, this message translates to:
  /// **'Ruku'**
  String get ruku;

  /// Number of Rukus in a Juz
  ///
  /// In en, this message translates to:
  /// **'{count} Rukus in Juz {juzNumber}'**
  String rukusInJuz(int count, int juzNumber);

  /// No description provided for @todayCount.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayCount;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalCount;

  /// No description provided for @customIncrement.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customIncrement;

  /// No description provided for @customIncrementDialog.
  ///
  /// In en, this message translates to:
  /// **'Custom Increment'**
  String get customIncrementDialog;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter number'**
  String get enterNumber;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today:'**
  String get todayLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get totalLabel;

  /// No description provided for @lastSevenDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get lastSevenDaysLabel;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
