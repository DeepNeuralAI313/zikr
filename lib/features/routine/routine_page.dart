import 'package:flutter/material.dart';
import '../../core/database_service.dart';
import '../../core/services/routine_service.dart';
import '../../core/services/reminder_service.dart';
import '../../generated/app_localizations.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});
  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final _dhikr = TextEditingController();
  final _rukus = TextEditingController();
  bool _loading = true, _saving = false, _reminders = false;
  TimeOfDay _dhikrTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _quranTime = const TimeOfDay(hour: 20, minute: 0);
  DateTime? _finish;
  int _read = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final config = await RoutineService.settings();
      final completed = await DatabaseService().completedRukuKeys();
      if (!mounted) return;
      setState(() {
        _dhikr.text = '${config['dhikrGoal'] ?? 100}';
        _rukus.text = '${config['rukuGoal'] ?? 2}';
        _reminders = config['reminders'] == true;
        final d = config['dhikrMinute'] as int? ?? 480;
        final q = config['quranMinute'] as int? ?? 1200;
        _dhikrTime = TimeOfDay(hour: d ~/ 60, minute: d % 60);
        _quranTime = TimeOfDay(hour: q ~/ 60, minute: q % 60);
        _finish = DateTime.tryParse(config['finishDate'] as String? ?? '');
        _read = completed.length;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dhikr.dispose();
    _rukus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final d = int.tryParse(_dhikr.text), r = int.tryParse(_rukus.text);
    if (d == null ||
        r == null ||
        d < 1 ||
        r < 1 ||
        d > 1000000 ||
        r > 1000000) {
      setState(() => _error = l.validGoals);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final config = <String, dynamic>{
      'dhikrGoal': d,
      'rukuGoal': r,
      'reminders': _reminders,
      'dhikrMinute': _dhikrTime.hour * 60 + _dhikrTime.minute,
      'quranMinute': _quranTime.hour * 60 + _quranTime.minute,
      'finishDate': _finish == null ? null : dayKey(_finish!),
    };
    try {
      final allowed =
          !_reminders ||
          await ReminderService.instance.schedule(
            config,
            requestPermission: true,
          );
      if (!allowed) {
        config['reminders'] = false;
      }
      if (!_reminders) await ReminderService.instance.schedule(config);
      await RoutineService.save(config);
      if (!mounted) return;
      setState(() {
        _reminders = config['reminders'] == true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(allowed ? l.routineSaved : l.notificationDenied),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = '${l.saveFailed}: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final days = _finish == null
        ? 0
        : RoutineService.daysRemaining(_finish!, DateTime.now());
    final remaining = (RoutineService.totalRukus - _read).clamp(
      0,
      RoutineService.totalRukus,
    );
    final daily = days > 0 ? (remaining / days).ceil() : 0;
    return Scaffold(
      appBar: AppBar(title: Text(l.dailyRoutine)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      l.personalGoals,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dhikr,
                      enabled: !_saving,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l.dailyDhikrGoal),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rukus,
                      enabled: !_saving,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l.dailyRukuGoal),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l.quranPlanner,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(l.plannerExplanation),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: Text(l.finishDate),
                      subtitle: Text(
                        _finish == null ? l.chooseDate : dayKey(_finish!),
                      ),
                      trailing: _finish == null
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _saving
                                  ? null
                                  : () => setState(() => _finish = null),
                            ),
                      onTap: _saving
                          ? null
                          : () async {
                              final now = DateUtils.dateOnly(DateTime.now());
                              final date = await showDatePicker(
                                context: context,
                                firstDate: now,
                                lastDate: DateTime(now.year + 10, 12, 31),
                                initialDate:
                                    _finish != null && !_finish!.isBefore(now)
                                    ? _finish!
                                    : now.add(const Duration(days: 30)),
                              );
                              if (date != null && mounted) {
                                setState(() => _finish = date);
                              }
                            },
                    ),
                    if (_finish != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${l.remainingRukus}: $remaining'),
                              Text(
                                days <= 0
                                    ? l.planExpired
                                    : '${l.rukusPerDay}: $daily',
                              ),
                              if (days > 0 && remaining > 0)
                                TextButton(
                                  onPressed: _saving
                                      ? null
                                      : () {
                                          setState(
                                            () => _rukus.text = '$daily',
                                          );
                                        },
                                  child: Text(l.useTarget),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.dailyReminders),
                      subtitle: Text(
                        ReminderService.supported
                            ? l.reminderExplanation
                            : l.mobileRemindersOnly,
                      ),
                      value: _reminders,
                      onChanged: _saving || !ReminderService.supported
                          ? null
                          : (v) => setState(() => _reminders = v),
                    ),
                    if (_reminders) ...[
                      for (final isDhikr in [true, false])
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            isDhikr ? l.dhikrReminder : l.quranReminder,
                          ),
                          trailing: Text(
                            (isDhikr ? _dhikrTime : _quranTime).format(context),
                          ),
                          onTap: _saving
                              ? null
                              : () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: isDhikr
                                        ? _dhikrTime
                                        : _quranTime,
                                  );
                                  if (time != null && mounted) {
                                    setState(() {
                                      if (isDhikr) {
                                        _dhikrTime = time;
                                      } else {
                                        _quranTime = time;
                                      }
                                    });
                                  }
                                },
                        ),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? l.saving : l.saveRoutine),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
