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

  @override
  String get currentSessionLabel => 'Current Session';

  @override
  String get previousSessionsLabel => 'Previous sessions';

  @override
  String get allTimeTotalLabel => 'All-Time Total';

  @override
  String get noCompletedSessionsMessage =>
      'No completed sessions yet. Your current count is included in today?s total and chart.';

  @override
  String get dailyRoutine => 'Daily routine';

  @override
  String get todaysRoutine => 'Today\'s routine';

  @override
  String get personalGoals => 'Your personal goals';

  @override
  String get dailyDhikrGoal => 'Daily dhikr goal';

  @override
  String get dailyRukuGoal => 'Daily ruku goal';

  @override
  String get validGoals => 'Enter whole numbers from 1 to 1,000,000.';

  @override
  String get quranPlanner => 'Quran completion planner';

  @override
  String get plannerExplanation =>
      'The target uses rukus you have marked as read. Saved places do not count as completed reading.';

  @override
  String get finishDate => 'Finish date';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get remainingRukus => 'Remaining rukus';

  @override
  String get rukusPerDay => 'Rukus per day';

  @override
  String get planExpired => 'Your finish date has passed. Choose a new date.';

  @override
  String get useTarget => 'Use this daily target';

  @override
  String get dailyReminders => 'Daily reminders';

  @override
  String get reminderExplanation =>
      'Choose local times. Delivery may be delayed by your phone\'s battery settings.';

  @override
  String get mobileRemindersOnly =>
      'Reminders are available on Android and iOS.';

  @override
  String get dhikrReminder => 'Dhikr reminder';

  @override
  String get quranReminder => 'Quran reminder';

  @override
  String get saveRoutine => 'Save routine';

  @override
  String get saving => 'Saving…';

  @override
  String get routineSaved => 'Your routine has been saved.';

  @override
  String get notificationDenied =>
      'Notifications are disabled. Enable them in your phone settings, then turn reminders on again.';

  @override
  String get saveFailed => 'Could not save';

  @override
  String get progressLoadFailed =>
      'Could not load progress. Reopen this screen to retry.';

  @override
  String get recordedRukusExplanation =>
      'Rukus marked as read today. Saving a place adds no reading credit.';

  @override
  String get routineComplete => 'Alhamdulillah, today\'s goals are complete.';

  @override
  String get guidedAdhkar => 'Morning & evening adhkar';

  @override
  String get morningAdhkar => 'Morning';

  @override
  String get eveningAdhkar => 'Evening';

  @override
  String get adhkarExplanation =>
      'A short guided collection. Morning and evening counts are saved separately each day and are separate from your main dhikr counters. Meanings below are in English.';

  @override
  String get completed => 'Completed';

  @override
  String get goalsAndReminders => 'Goals, reading plan and reminder times';

  @override
  String get createBackup => 'Save backup file';

  @override
  String get backupExplanation =>
      'Includes counts, history, custom dhikr, routine and guided adhkar. Keep a copy somewhere safe.';

  @override
  String get shareBackup => 'Share backup';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get exportCsv => 'Export progress as CSV';

  @override
  String get fileSaved => 'File saved.';

  @override
  String get confirmAction => 'Continue';

  @override
  String get backupTooLarge => 'Choose a backup smaller than 25 MB.';

  @override
  String get restoreWarning =>
      'This replaces all current counts, history, custom dhikr, routine and guided adhkar with the backup. Save a backup of your current data first.';

  @override
  String get backupRestored => 'Backup restored.';

  @override
  String get reminderRestoreFailed =>
      'Data restored. Open Daily routine to set up reminders again.';

  @override
  String get resetProgress => 'Reset all progress';

  @override
  String get resetWarning =>
      'This clears all dhikr counts, session history, Quran progress and guided adhkar counts. Custom dhikr and routine settings are kept. Save a backup first. This cannot be undone.';

  @override
  String get progressReset => 'Progress reset.';

  @override
  String get homeWidget => 'Android home-screen widget';

  @override
  String get widgetInstructions =>
      'On Android, long-press your home screen, choose Widgets, then Dhikr. Tap the widget to open your counters.';

  @override
  String get localPrivacy => 'Your data stays on your device';

  @override
  String get privacyExplanation =>
      'No account or cloud sync is required. Backup files contain your progress; you choose where to save or share them.';

  @override
  String get appVersion => 'App version';

  @override
  String get csvExplanation =>
      'Save a spreadsheet of your progress. This file is for viewing, not restoring.';

  @override
  String get shareBackupExplanation => 'Share a JSON backup using another app.';

  @override
  String get restoreBackupExplanation =>
      'Choose a JSON backup file to restore.';

  @override
  String get adhkarCollectionsExplanation =>
      'Morning and evening are separate lists. Add, edit or remove entries independently. Choose text size, transliteration and meaning language in Appearance.';

  @override
  String get emptyAdhkarCollection =>
      'This list is empty. Add your first dhikr above.';

  @override
  String get editDhikr => 'Edit dhikr';

  @override
  String get deleteDhikr => 'Delete dhikr';

  @override
  String get deleteGuidedWarning =>
      'Remove this dhikr from this list? The other list and its counts are kept.';

  @override
  String get addToCollection => 'Add to';

  @override
  String get bothCollections => 'Morning and evening';

  @override
  String get sourceOptional => 'Reference (optional)';

  @override
  String get repetitionTarget => 'Repetitions';

  @override
  String get saveDhikr => 'Save dhikr';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSummary => 'Language, theme and reading controls';

  @override
  String get yourData => 'Your data';

  @override
  String get yourDataSummary => 'Back up, restore or export your progress';

  @override
  String get arabicTextSize => 'Arabic text size';

  @override
  String get meaningTextSize => 'Meaning text size';

  @override
  String get showTransliteration => 'Show transliteration';

  @override
  String get meaningLanguage => 'Meaning language';

  @override
  String get followAppLanguage => 'Follow app language';

  @override
  String get meaningFallbackExplanation =>
      'Urdu meanings are available for built-in entries. Other entries use their saved meaning.';

  @override
  String get readingPreview => 'Reading preview';

  @override
  String get transliterationOptional => 'Transliteration (optional)';

  @override
  String get urduMeaningOptional => 'Urdu meaning (optional)';

  @override
  String get saveMyPlace => 'Save my place';

  @override
  String get bookmarkOnlyExplanation =>
      'Save where to resume. This does not mark the ruku as read.';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get completionExplanation =>
      'Record this ruku as completed today and update your saved place.';

  @override
  String get undoCompletion => 'Undo today’s completion';

  @override
  String get undoCompletionExplanation =>
      'Remove this ruku from today’s completed reading. Your saved place is kept.';

  @override
  String get bookmarkSaved => 'Your reading place has been saved.';

  @override
  String get readingRecorded => 'Ruku marked as read for today.';

  @override
  String get completionRemoved => 'Today’s completion was removed.';

  @override
  String get quranTrackingExplanation =>
      'Tap a ruku to save your place or mark it as read. Checkmarks show what you completed today.';
}
