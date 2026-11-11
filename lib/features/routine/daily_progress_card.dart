import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/database_service.dart';
import '../../core/services/routine_service.dart';
import '../../generated/app_localizations.dart';

class DailyProgressCard extends StatefulWidget {
  const DailyProgressCard({super.key});
  @override
  State<DailyProgressCard> createState() => _DailyProgressCardState();
}

class _DailyProgressCardState extends State<DailyProgressCard>
    with WidgetsBindingObserver {
  late Future<(Map<String, dynamic>, int, int)> _data;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    RoutineService.changes.addListener(_refresh);
    _data = _load();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
  }

  Future<(Map<String, dynamic>, int, int)> _load() async => (
    await RoutineService.settings(),
    await DatabaseService().getTodayTotalAllZikr(),
    await RoutineService.todayRukus(),
  );
  void _refresh() {
    if (mounted) {
      final data = _load();
      setState(() {
        _data = data;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    RoutineService.changes.removeListener(_refresh);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.pushNamed(context, '/routine');
          _refresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.todaysRoutine,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder(
                future: _data,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(l.progressLoadFailed);
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  final (config, dhikr, rukus) = snapshot.data!;
                  final dg = config['dhikrGoal'] as int? ?? 100;
                  final rg = config['rukuGoal'] as int? ?? 2;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l.zikr}: $dhikr / $dg'),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: dg <= 0 ? 0 : (dhikr / dg).clamp(0, 1),
                      ),
                      const SizedBox(height: 14),
                      Text('${l.ruku}: $rukus / $rg'),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: rg <= 0 ? 0 : (rukus / rg).clamp(0, 1),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.recordedRukusExplanation,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (dhikr >= dg && rukus >= rg) Text(l.routineComplete),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
