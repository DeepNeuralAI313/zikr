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

  /// No description provided for @currentSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Session'**
  String get currentSessionLabel;

  /// No description provided for @previousSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous sessions'**
  String get previousSessionsLabel;

  /// No description provided for @allTimeTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'All-Time Total'**
  String get allTimeTotalLabel;

  /// No description provided for @noCompletedSessionsMessage.
  ///
  /// In en, this message translates to:
  /// **'No completed sessions yet. Your current count is included in today?s total and chart.'**
  String get noCompletedSessionsMessage;

  /// No description provided for @dailyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Daily routine'**
  String get dailyRoutine;

  /// No description provided for @todaysRoutine.
  ///
  /// In en, this message translates to:
  /// **'Today\'s routine'**
  String get todaysRoutine;

  /// No description provided for @personalGoals.
  ///
  /// In en, this message translates to:
  /// **'Your personal goals'**
  String get personalGoals;

  /// No description provided for @dailyDhikrGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily dhikr goal'**
  String get dailyDhikrGoal;

  /// No description provided for @dailyRukuGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily ruku goal'**
  String get dailyRukuGoal;

  /// No description provided for @validGoals.
  ///
  /// In en, this message translates to:
  /// **'Enter whole numbers from 1 to 1,000,000.'**
  String get validGoals;

  /// No description provided for @quranPlanner.
  ///
  /// In en, this message translates to:
  /// **'Quran completion planner'**
  String get quranPlanner;

  /// No description provided for @plannerExplanation.
  ///
  /// In en, this message translates to:
  /// **'The target uses rukus you have marked as read. Saved places do not count as completed reading.'**
  String get plannerExplanation;

  /// No description provided for @finishDate.
  ///
  /// In en, this message translates to:
  /// **'Finish date'**
  String get finishDate;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get chooseDate;

  /// No description provided for @remainingRukus.
  ///
  /// In en, this message translates to:
  /// **'Remaining rukus'**
  String get remainingRukus;

  /// No description provided for @rukusPerDay.
  ///
  /// In en, this message translates to:
  /// **'Rukus per day'**
  String get rukusPerDay;

  /// No description provided for @planExpired.
  ///
  /// In en, this message translates to:
  /// **'Your finish date has passed. Choose a new date.'**
  String get planExpired;

  /// No description provided for @useTarget.
  ///
  /// In en, this message translates to:
  /// **'Use this daily target'**
  String get useTarget;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get dailyReminders;

  /// No description provided for @reminderExplanation.
  ///
  /// In en, this message translates to:
  /// **'Choose local times. Delivery may be delayed by your phone\'s battery settings.'**
  String get reminderExplanation;

  /// No description provided for @mobileRemindersOnly.
  ///
  /// In en, this message translates to:
  /// **'Reminders are available on Android and iOS.'**
  String get mobileRemindersOnly;

  /// No description provided for @dhikrReminder.
  ///
  /// In en, this message translates to:
  /// **'Dhikr reminder'**
  String get dhikrReminder;

  /// No description provided for @quranReminder.
  ///
  /// In en, this message translates to:
  /// **'Quran reminder'**
  String get quranReminder;

  /// No description provided for @saveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save routine'**
  String get saveRoutine;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @routineSaved.
  ///
  /// In en, this message translates to:
  /// **'Your routine has been saved.'**
  String get routineSaved;

  /// No description provided for @notificationDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Enable them in your phone settings, then turn reminders on again.'**
  String get notificationDenied;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save'**
  String get saveFailed;

  /// No description provided for @progressLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load progress. Reopen this screen to retry.'**
  String get progressLoadFailed;

  /// No description provided for @recordedRukusExplanation.
  ///
  /// In en, this message translates to:
  /// **'Rukus marked as read today. Saving a place adds no reading credit.'**
  String get recordedRukusExplanation;

  /// No description provided for @routineComplete.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah, today\'s goals are complete.'**
  String get routineComplete;

  /// No description provided for @guidedAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Morning & evening adhkar'**
  String get guidedAdhkar;

  /// No description provided for @morningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morningAdhkar;

  /// No description provided for @eveningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get eveningAdhkar;

  /// No description provided for @adhkarExplanation.
  ///
  /// In en, this message translates to:
  /// **'A short guided collection. Morning and evening counts are saved separately each day and are separate from your main dhikr counters. Meanings below are in English.'**
  String get adhkarExplanation;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @goalsAndReminders.
  ///
  /// In en, this message translates to:
  /// **'Goals, reading plan and reminder times'**
  String get goalsAndReminders;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Save backup file'**
  String get createBackup;

  /// No description provided for @backupExplanation.
  ///
  /// In en, this message translates to:
  /// **'Includes counts, history, custom dhikr, routine and guided adhkar. Keep a copy somewhere safe.'**
  String get backupExplanation;

  /// No description provided for @shareBackup.
  ///
  /// In en, this message translates to:
  /// **'Share backup'**
  String get shareBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export progress as CSV'**
  String get exportCsv;

  /// No description provided for @fileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved.'**
  String get fileSaved;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get confirmAction;

  /// No description provided for @backupTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup smaller than 25 MB.'**
  String get backupTooLarge;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'This replaces all current counts, history, custom dhikr, routine and guided adhkar with the backup. Save a backup of your current data first.'**
  String get restoreWarning;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get backupRestored;

  /// No description provided for @reminderRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Data restored. Open Daily routine to set up reminders again.'**
  String get reminderRestoreFailed;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress'**
  String get resetProgress;

  /// No description provided for @resetWarning.
  ///
  /// In en, this message translates to:
  /// **'This clears all dhikr counts, session history, Quran progress and guided adhkar counts. Custom dhikr and routine settings are kept. Save a backup first. This cannot be undone.'**
  String get resetWarning;

  /// No description provided for @progressReset.
  ///
  /// In en, this message translates to:
  /// **'Progress reset.'**
  String get progressReset;

  /// No description provided for @homeWidget.
  ///
  /// In en, this message translates to:
  /// **'Android home-screen widget'**
  String get homeWidget;

  /// No description provided for @widgetInstructions.
  ///
  /// In en, this message translates to:
  /// **'On Android, long-press your home screen, choose Widgets, then Dhikr. Tap the widget to open your counters.'**
  String get widgetInstructions;

  /// No description provided for @localPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get localPrivacy;

  /// No description provided for @privacyExplanation.
  ///
  /// In en, this message translates to:
  /// **'No account or cloud sync is required. Backup files contain your progress; you choose where to save or share them.'**
  String get privacyExplanation;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @csvExplanation.
  ///
  /// In en, this message translates to:
  /// **'Save a spreadsheet of your progress. This file is for viewing, not restoring.'**
  String get csvExplanation;

  /// No description provided for @shareBackupExplanation.
  ///
  /// In en, this message translates to:
  /// **'Share a JSON backup using another app.'**
  String get shareBackupExplanation;

  /// No description provided for @restoreBackupExplanation.
  ///
  /// In en, this message translates to:
  /// **'Choose a JSON backup file to restore.'**
  String get restoreBackupExplanation;

  /// No description provided for @adhkarCollectionsExplanation.
  ///
  /// In en, this message translates to:
  /// **'Morning and evening are separate lists. Add, edit or remove entries independently. Choose text size, transliteration and meaning language in Appearance.'**
  String get adhkarCollectionsExplanation;

  /// No description provided for @emptyAdhkarCollection.
  ///
  /// In en, this message translates to:
  /// **'This list is empty. Add your first dhikr above.'**
  String get emptyAdhkarCollection;

  /// No description provided for @editDhikr.
  ///
  /// In en, this message translates to:
  /// **'Edit dhikr'**
  String get editDhikr;

  /// No description provided for @deleteDhikr.
  ///
  /// In en, this message translates to:
  /// **'Delete dhikr'**
  String get deleteDhikr;

  /// No description provided for @deleteGuidedWarning.
  ///
  /// In en, this message translates to:
  /// **'Remove this dhikr from this list? The other list and its counts are kept.'**
  String get deleteGuidedWarning;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to'**
  String get addToCollection;

  /// No description provided for @bothCollections.
  ///
  /// In en, this message translates to:
  /// **'Morning and evening'**
  String get bothCollections;

  /// No description provided for @sourceOptional.
  ///
  /// In en, this message translates to:
  /// **'Reference (optional)'**
  String get sourceOptional;

  /// No description provided for @repetitionTarget.
  ///
  /// In en, this message translates to:
  /// **'Repetitions'**
  String get repetitionTarget;

  /// No description provided for @saveDhikr.
  ///
  /// In en, this message translates to:
  /// **'Save dhikr'**
  String get saveDhikr;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Language, theme and reading controls'**
  String get appearanceSummary;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @yourDataSummary.
  ///
  /// In en, this message translates to:
  /// **'Back up, restore or export your progress'**
  String get yourDataSummary;

  /// No description provided for @arabicTextSize.
  ///
  /// In en, this message translates to:
  /// **'Arabic text size'**
  String get arabicTextSize;

  /// No description provided for @meaningTextSize.
  ///
  /// In en, this message translates to:
  /// **'Meaning text size'**
  String get meaningTextSize;

  /// No description provided for @showTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Show transliteration'**
  String get showTransliteration;

  /// No description provided for @meaningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Meaning language'**
  String get meaningLanguage;

  /// No description provided for @followAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Follow app language'**
  String get followAppLanguage;

  /// No description provided for @meaningFallbackExplanation.
  ///
  /// In en, this message translates to:
  /// **'Urdu meanings are available for built-in entries. Other entries use their saved meaning.'**
  String get meaningFallbackExplanation;

  /// No description provided for @readingPreview.
  ///
  /// In en, this message translates to:
  /// **'Reading preview'**
  String get readingPreview;

  /// No description provided for @transliterationOptional.
  ///
  /// In en, this message translates to:
  /// **'Transliteration (optional)'**
  String get transliterationOptional;

  /// No description provided for @urduMeaningOptional.
  ///
  /// In en, this message translates to:
  /// **'Urdu meaning (optional)'**
  String get urduMeaningOptional;

  /// No description provided for @saveMyPlace.
  ///
  /// In en, this message translates to:
  /// **'Save my place'**
  String get saveMyPlace;

  /// No description provided for @bookmarkOnlyExplanation.
  ///
  /// In en, this message translates to:
  /// **'Save where to resume. This does not mark the ruku as read.'**
  String get bookmarkOnlyExplanation;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @completionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Record this ruku as completed today and update your saved place.'**
  String get completionExplanation;

  /// No description provided for @undoCompletion.
  ///
  /// In en, this message translates to:
  /// **'Undo today’s completion'**
  String get undoCompletion;

  /// No description provided for @undoCompletionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Remove this ruku from today’s completed reading. Your saved place is kept.'**
  String get undoCompletionExplanation;

  /// No description provided for @bookmarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Your reading place has been saved.'**
  String get bookmarkSaved;

  /// No description provided for @readingRecorded.
  ///
  /// In en, this message translates to:
  /// **'Ruku marked as read for today.'**
  String get readingRecorded;

  /// No description provided for @completionRemoved.
  ///
  /// In en, this message translates to:
  /// **'Today’s completion was removed.'**
  String get completionRemoved;

  /// No description provided for @quranTrackingExplanation.
  ///
  /// In en, this message translates to:
  /// **'Tap a ruku to save your place or mark it as read. Checkmarks show what you completed today.'**
  String get quranTrackingExplanation;
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
