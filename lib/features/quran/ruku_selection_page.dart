import 'package:flutter/material.dart';
import '../../core/database_service.dart';
import '../../core/services/quran_data_service.dart';
import '../../core/services/routine_service.dart';
import '../../generated/app_localizations.dart';

class RukuSelectionPage extends StatefulWidget {
  final int juzNumber;
  const RukuSelectionPage({super.key, required this.juzNumber});
  @override
  State<RukuSelectionPage> createState() => _RukuSelectionPageState();
}

class _RukuSelectionPageState extends State<RukuSelectionPage> {
  int _count = 0;
  Set<String> _completed = {};
  bool _loading = true, _busy = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await QuranDataService.instance.loadData();
      final completed = await DatabaseService().completedRukuKeys(
        date: dayKey(DateTime.now()),
      );
      if (mounted)
        setState(() {
          _count = QuranDataService.instance.getRukuCount(widget.juzNumber);
          _completed = completed;
          _loading = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _select(int ruku) async {
    if (_busy) return;
    final l = AppLocalizations.of(context)!;
    final done = _completed.contains('${widget.juzNumber}:$ruku');
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l.juz} ${widget.juzNumber} · ${l.ruku} $ruku',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListTile(
                  key: const ValueKey('save-quran-bookmark'),
                  leading: const Icon(Icons.bookmark_outline),
                  title: Text(l.saveMyPlace),
                  subtitle: Text(l.bookmarkOnlyExplanation),
                  onTap: () => Navigator.pop(ctx, 'bookmark'),
                ),
                ListTile(
                  key: const ValueKey('mark-quran-completed'),
                  leading: Icon(done ? Icons.undo : Icons.check_circle_outline),
                  title: Text(done ? l.undoCompletion : l.markAsRead),
                  subtitle: Text(
                    done
                        ? l.undoCompletionExplanation
                        : l.completionExplanation,
                  ),
                  onTap: () => Navigator.pop(ctx, done ? 'undo' : 'complete'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (action == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final database = DatabaseService();
      if (action == 'bookmark') {
        await database.saveQuranProgress(
          juzNumber: widget.juzNumber,
          rukuNumber: ruku,
        );
      } else if (action == 'complete') {
        await database.markRukuCompleted(
          juzNumber: widget.juzNumber,
          rukuNumber: ruku,
        );
      } else {
        await database.undoRukuCompletion(widget.juzNumber, ruku);
      }
      RoutineService.progressChanged();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'bookmark'
                ? l.bookmarkSaved
                : action == 'complete'
                ? l.readingRecorded
                : l.completionRemoved,
          ),
        ),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l.juz} ${widget.juzNumber} · ${l.selectRuku}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.chooseRuku,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(l.quranTrackingExplanation),
                  const SizedBox(height: 12),
                  if (_busy) const LinearProgressIndicator(),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 90,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: _count,
                      itemBuilder: (context, index) {
                        final ruku = index + 1;
                        final done = _completed.contains(
                          '${widget.juzNumber}:$ruku',
                        );
                        return Card(
                          color: done
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : null,
                          child: InkWell(
                            key: ValueKey('ruku-$ruku'),
                            borderRadius: BorderRadius.circular(12),
                            onTap: _busy ? null : () => _select(ruku),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$ruku',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (done)
                                  Icon(
                                    Icons.check,
                                    size: 18,
                                    semanticLabel: l.completed,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
