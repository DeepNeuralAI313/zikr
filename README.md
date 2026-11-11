# zikr

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android release builds on Windows

Configure your upload keystore in the ignored `android/key.properties` file, then run:

```powershell
./scripts/build_android_release.ps1
```

The script runs dependency setup with desktop-only symlinks disabled for this process, checks that Flutter generated its Android plugin registrant, and builds the signed APK and app bundle. It then verifies the actual DEX class definitions in both packages so a missing native plugin registrant fails the build. Use `-ApkOnly` to build only the APK. Do not publish a build made after a failed dependency setup with only `flutter build --no-pub`.

Keep the upload keystore and its passwords in a secure backup. Never commit `android/key.properties` or a private keystore.

## Daily routine and data tools

The home screen includes a daily routine card, morning/evening adhkar, and Settings.

- **Daily routine:** set dhikr and ruku goals. Dhikr progress uses today's existing counter totals. Quran progress counts distinct rukus explicitly marked as read today. Saving a bookmark only updates your place. Marking the same ruku twice in one day counts once; undo removes today's completion only.
- **Completion planner:** choose an inclusive finish date. The remaining workload uses the bundled ruku counts minus distinct rukus explicitly marked as read, without assuming skipped locations were completed. Apply its suggested daily target with “Use this daily target.”
- **Reminders:** Android/iOS local notifications at two chosen local times. Permission is requested when enabling them. Schedules are refreshed on app resume to pick up timezone changes; Android restores them after reboot. Delivery is approximate and depends on OS battery settings.
- **Guided adhkar:** a short collection containing Quran 112–114 (three repetitions each, Abu Dawud 5082) and SubhanAllahi wa bihamdihi (100 repetitions, Muslim 2692). Morning/evening progress is separate, persists across restarts, and starts fresh each day. These counts remain separate from the main dhikr counters. Arabic originals, optional transliteration and English or Urdu meanings are displayed, with source references. Appearance controls adjust Arabic and meaning sizes; custom items can include transliteration and an Urdu meaning.
- **Backup/restore:** save a JSON file or use the system share sheet. Includes counters, sessions, Quran bookmarks and explicit completions, custom dhikr, routine settings, guided progress and reading preferences. Version 2 backups retain compatibility with version 1 imports; older bookmarks do not create completion credit. Restore replaces these records after validation and confirmation. Database changes use a transaction, and preferences are restored on database failure. Backups are local, unencrypted files; store them privately. There is no account or automatic cloud sync.
- **CSV:** export active counters, completed sessions, Quran bookmark history and explicitly completed rukus as separate record types. CSV is for viewing; use JSON for restoration.
- **Reset:** clears counts and history after confirmation, keeping custom dhikr and routine settings.
- **Android widget:** long-press the launcher, select Widgets, then Dhikr. Displays daily totals/goals and opens the counter list. Updates after progress changes; Android also refreshes periodically and clears the previous day's display. Launcher refresh timing varies. iOS widgets are not included.

The new interface strings support English, Arabic and Urdu. Run `flutter test --no-pub` for history, routine, backup validation/rollback, and widget-layout checks. Phone notification delivery, file pickers/share sheets and launcher widgets should also be checked on an Android device before release.

Morning and evening collections can now be managed separately. Use **Add Custom Dhikr** to add an item to morning, evening, or both; each card has Edit and Delete actions. Editing or deleting one list does not modify the other. Stable entry IDs preserve counts when items are renamed or removed, including counts saved before this update. Each list includes a time-specific dua in addition to the shared adhkar. JSON backups include the customized lists; resetting progress keeps the lists and clears their counts.

Settings groups controls into Appearance (language, theme and reading), Daily routine (goals, planner and reminders), and Your data (backup, restore, export and reset). Data actions use fixed rows with a loading overlay, so picker errors and loading indicators do not shift touch targets. Repeated actions are blocked while an operation is active. CSV export, JSON backup, JSON restore and sharing have separate actions and descriptions. Widget instructions and privacy rows open their corresponding information dialogs. The internal app version is not displayed in Settings.
