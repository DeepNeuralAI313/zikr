import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/reminder_service.dart';
import '../../core/services/routine_service.dart';
import '../../generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final bool dataOnly;
  const SettingsScreen({super.key, this.dataOnly = false});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;
  bool _openingRoutine = false;
  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy || _openingRoutine) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      _message('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openRoutine() async {
    await _openPage('/routine');
  }

  Future<void> _openPage(String route) async {
    if (_busy || _openingRoutine) return;
    _openingRoutine = true;
    try {
      await Navigator.pushNamed(context, route);
    } finally {
      _openingRoutine = false;
    }
  }

  void _showInfo(String title, String body) {
    if (_busy || _openingRoutine) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.close),
          ),
        ],
      ),
    );
  }

  Future<void> _export(bool backup) async {
    final l = AppLocalizations.of(context)!;
    final content = backup
        ? await BackupService.exportJson()
        : await BackupService.exportCsv();
    final name =
        'dhikr-${backup ? 'backup' : 'progress'}-${DateTime.now().millisecondsSinceEpoch}.${backup ? 'json' : 'csv'}';
    final bytes = Uint8List.fromList(utf8.encode(content));
    final saved = await FilePicker.platform.saveFile(
      dialogTitle: backup ? l.createBackup : l.exportCsv,
      fileName: name,
      type: FileType.custom,
      allowedExtensions: [backup ? 'json' : 'csv'],
      bytes: bytes,
    );
    if (saved == null) return;
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await File(saved).writeAsBytes(bytes, flush: true);
    }
    _message(l.fileSaved);
  }

  Future<void> _shareBackup() async {
    final content = await BackupService.exportJson();
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        title: AppLocalizations.of(context)!.shareBackup,
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(content)),
            mimeType: 'application/json',
          ),
        ],
        fileNameOverrides: ['dhikr-backup.json'],
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<bool> _confirm(String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(ctx)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(ctx)!.confirmAction),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> _restore() async {
    final l = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
    );
    if (result == null) return;
    final file = result.files.single;
    if (file.size > 25 * 1024 * 1024) throw FormatException(l.backupTooLarge);
    final content = file.bytes != null
        ? utf8.decode(file.bytes!)
        : await File(file.path!).readAsString();
    BackupService.validate(jsonDecode(content) as Map<String, dynamic>);
    if (!mounted || !await _confirm(l.restoreBackup, l.restoreWarning)) return;
    await BackupService.restore(content);
    _message(l.backupRestored);
    try {
      final allowed = await ReminderService.instance.schedule(
        await RoutineService.settings(),
      );
      if (!allowed && ReminderService.supported) _message(l.notificationDenied);
    } catch (_) {
      _message(l.reminderRestoreFailed);
    }
    await RoutineService.updateWidget();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.dataOnly ? l.yourData : l.settings)),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _busy,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (!widget.dataOnly) ...[
                      ListTile(
                        key: const ValueKey('settings-appearance'),
                        leading: const Icon(Icons.text_fields),
                        title: Text(l.appearance),
                        subtitle: Text(l.appearanceSummary),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openPage('/appearance'),
                      ),
                      ListTile(
                        key: const ValueKey('settings-routine'),
                        leading: const Icon(Icons.schedule),
                        title: Text(l.dailyRoutine),
                        subtitle: Text(l.goalsAndReminders),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _openRoutine,
                      ),
                      ListTile(
                        key: const ValueKey('settings-data'),
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(l.yourData),
                        subtitle: Text(l.yourDataSummary),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openPage('/data-settings'),
                      ),
                    ],
                    if (widget.dataOnly) ...[
                      const Divider(),
                      ListTile(
                        key: const ValueKey('settings-backup'),
                        leading: const Icon(Icons.save_alt),
                        title: Text(l.createBackup),
                        subtitle: Text(l.backupExplanation),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _run(() => _export(true)),
                      ),
                      if (!kIsWeb &&
                          (Platform.isAndroid ||
                              Platform.isIOS ||
                              Platform.isWindows ||
                              Platform.isMacOS))
                        ListTile(
                          key: const ValueKey('settings-share'),
                          leading: const Icon(Icons.share),
                          title: Text(l.shareBackup),
                          subtitle: Text(l.shareBackupExplanation),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _run(_shareBackup),
                        ),
                      ListTile(
                        key: const ValueKey('settings-restore'),
                        leading: const Icon(Icons.restore),
                        title: Text(l.restoreBackup),
                        subtitle: Text(l.restoreBackupExplanation),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _run(_restore),
                      ),
                      ListTile(
                        key: const ValueKey('settings-csv'),
                        leading: const Icon(Icons.table_chart_outlined),
                        title: Text(l.exportCsv),
                        subtitle: Text(l.csvExplanation),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _run(() => _export(false)),
                      ),
                      ListTile(
                        key: const ValueKey('settings-reset'),
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: Text(l.resetProgress),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _run(() async {
                          if (await _confirm(l.resetProgress, l.resetWarning)) {
                            await BackupService.resetProgress();
                            _message(l.progressReset);
                          }
                        }),
                      ),
                    ],
                    if (!widget.dataOnly) ...[
                      const Divider(),
                      ListTile(
                        key: const ValueKey('settings-widget'),
                        leading: const Icon(Icons.widgets_outlined),
                        title: Text(l.homeWidget),
                        subtitle: Text(l.widgetInstructions),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            _showInfo(l.homeWidget, l.widgetInstructions),
                      ),
                      ListTile(
                        key: const ValueKey('settings-privacy'),
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(l.localPrivacy),
                        subtitle: Text(l.privacyExplanation),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            _showInfo(l.localPrivacy, l.privacyExplanation),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_busy)
            const Positioned.fill(
              key: ValueKey('settings-busy'),
              child: Stack(
                children: [
                  ModalBarrier(dismissible: false, color: Color(0x22000000)),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
