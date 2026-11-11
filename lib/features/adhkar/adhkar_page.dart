import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/adhkar_service.dart';
import '../../core/services/routine_service.dart';
import '../../core/services/reading_preferences.dart';
import '../../generated/app_localizations.dart';

class AdhkarPage extends StatefulWidget {
  const AdhkarPage({super.key});
  @override
  State<AdhkarPage> createState() => _AdhkarPageState();
}

class _AdhkarPageState extends State<AdhkarPage> with WidgetsBindingObserver {
  bool _morning = DateTime.now().hour < 12, _loading = true, _busy = false;
  bool _loadFailed = false;
  Map<String, List<AdhkarEntry>> _collections = {'morning': [], 'evening': []};
  Map<String, dynamic> _counts = {};
  String get _lane => _morning ? 'morning' : 'evening';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      await ReadingPreferences.instance.load();
      final collections = await AdhkarService.load();
      final prefs = await SharedPreferences.getInstance();
      final counts =
          jsonDecode(prefs.getString(AdhkarService.countsKey) ?? '{}')
              as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _collections = collections;
          _counts = counts;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _error(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  String _key(String id) => '${dayKey(DateTime.now())}:$_lane:$id';
  Future<void> _count(AdhkarEntry entry) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final key = _key(entry.id);
      final next = Map<String, dynamic>.from(
        _counts,
      )..removeWhere((key, _) => !key.startsWith('${dayKey(DateTime.now())}:'));
      next[key] = ((next[key] as int? ?? 0) + 1).clamp(0, entry.repetitions);
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(AdhkarService.countsKey, jsonEncode(next))) {
        throw StateError('Save failed');
      }
      if (mounted) setState(() => _counts = next);
    } catch (e) {
      _error(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit([AdhkarEntry? entry]) async {
    if (_busy || _loading || _loadFailed) return;
    final lane = _lane;
    final result = await showDialog<(AdhkarEntry, String)>(
      context: context,
      builder: (_) =>
          _AdhkarEditor(entry: entry, lane: lane, collections: _collections),
    );
    if (result == null || !mounted) return;
    final next = {
      for (final pair in _collections.entries)
        pair.key: List<AdhkarEntry>.of(pair.value),
    };
    for (final target
        in result.$2 == 'both' ? ['morning', 'evening'] : [result.$2]) {
      final index = next[target]!.indexWhere((item) => item.id == result.$1.id);
      if (index < 0) {
        next[target]!.add(result.$1);
      } else {
        next[target]![index] = result.$1;
      }
    }
    await _save(next);
  }

  Future<void> _save(Map<String, List<AdhkarEntry>> next) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await AdhkarService.save(next);
      if (mounted) setState(() => _collections = next);
    } catch (e) {
      _error(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(AdhkarEntry entry) async {
    if (_busy) return;
    final l = AppLocalizations.of(context)!;
    final lane = _lane;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteDhikr),
        content: Text('${entry.title}\n\n${l.deleteGuidedWarning}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.deleteDhikr),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final next = {
      for (final pair in _collections.entries)
        pair.key: List<AdhkarEntry>.of(pair.value),
    };
    next[lane]!.removeWhere((item) => item.id == entry.id);
    await _save(next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final entries = _collections[_lane]!;
    return Scaffold(
      appBar: AppBar(title: Text(l.guidedAdhkar)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: true,
                          label: Text(l.morningAdhkar),
                          icon: const Icon(Icons.wb_sunny_outlined),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text(l.eveningAdhkar),
                          icon: const Icon(Icons.nights_stay_outlined),
                        ),
                      ],
                      selected: {_morning},
                      onSelectionChanged: _busy || _loading
                          ? null
                          : (s) => setState(() => _morning = s.first),
                    ),
                    const SizedBox(height: 12),
                    Text(l.adhkarCollectionsExplanation),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const ValueKey('add-guided-dhikr'),
                      onPressed: _busy || _loading || _loadFailed
                          ? null
                          : () => _edit(),
                      icon: const Icon(Icons.add),
                      label: Text(l.addCustomZikr),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadFailed
                    ? Center(
                        child: TextButton(
                          onPressed: _load,
                          child: Text(l.progressLoadFailed),
                        ),
                      )
                    : entries.isEmpty
                    ? Center(child: Text(l.emptyAdhkarCollection))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: entries.length,
                        itemBuilder: (_, index) => _entry(entries[index], l),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entry(AdhkarEntry entry, AppLocalizations l) {
    return ListenableBuilder(
      listenable: ReadingPreferences.instance,
      builder: (context, _) {
        final reading = ReadingPreferences.instance;
        final meaning =
            reading.useUrdu(Localizations.localeOf(context).languageCode) &&
                entry.urduMeaning.isNotEmpty
            ? entry.urduMeaning
            : entry.translation;
        final count = _counts[_key(entry.id)] as int? ?? 0;
        return Card(
          key: ValueKey('entry-$_lane-${entry.id}'),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      key: ValueKey('edit-$_lane-${entry.id}'),
                      tooltip: l.editDhikr,
                      onPressed: _busy ? null : () => _edit(entry),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      key: ValueKey('delete-$_lane-${entry.id}'),
                      tooltip: l.deleteDhikr,
                      onPressed: _busy ? null : () => _delete(entry),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                if (entry.arabic.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    entry.arabic,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: reading.arabicSize, height: 1.8),
                  ),
                ],
                if (reading.showTransliteration &&
                    entry.transliteration.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    entry.transliteration,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: reading.meaningSize),
                  ),
                ],
                if (meaning.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    meaning,
                    style: TextStyle(fontSize: reading.meaningSize),
                    textDirection: RegExp(r'[\u0600-\u06ff]').hasMatch(meaning)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                ],
                if (entry.reference.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    entry.reference,
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (count / entry.repetitions).clamp(0, 1),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: ValueKey('count-$_lane-${entry.id}'),
                  onPressed: _busy || count >= entry.repetitions
                      ? null
                      : () => _count(entry),
                  icon: Icon(
                    count >= entry.repetitions ? Icons.check : Icons.add,
                  ),
                  label: Text(
                    '${count >= entry.repetitions ? l.completed : l.tapToCount} · $count / ${entry.repetitions}',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdhkarEditor extends StatefulWidget {
  final AdhkarEntry? entry;
  final String lane;
  final Map<String, List<AdhkarEntry>> collections;
  const _AdhkarEditor({
    this.entry,
    required this.lane,
    required this.collections,
  });
  @override
  State<_AdhkarEditor> createState() => _AdhkarEditorState();
}

class _AdhkarEditorState extends State<_AdhkarEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title,
      _arabic,
      _meaning,
      _transliteration,
      _urdu,
      _reference,
      _target;
  late String _lane;
  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _lane = widget.lane;
    _title = TextEditingController(text: e?.title ?? '');
    _arabic = TextEditingController(text: e?.arabic ?? '');
    _meaning = TextEditingController(text: e?.translation ?? '');
    _transliteration = TextEditingController(text: e?.transliteration ?? '');
    _urdu = TextEditingController(text: e?.urduMeaning ?? '');
    _reference = TextEditingController(text: e?.reference ?? '');
    _target = TextEditingController(text: '${e?.repetitions ?? 33}');
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _arabic,
      _meaning,
      _transliteration,
      _urdu,
      _reference,
      _target,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.entry == null ? l.addCustomZikr : l.editDhikr),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.entry == null)
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _lane,
                    decoration: InputDecoration(labelText: l.addToCollection),
                    items: [
                      DropdownMenuItem(
                        value: 'morning',
                        child: Text(l.morningAdhkar),
                      ),
                      DropdownMenuItem(
                        value: 'evening',
                        child: Text(l.eveningAdhkar),
                      ),
                      DropdownMenuItem(
                        value: 'both',
                        child: Text(l.bothCollections),
                      ),
                    ],
                    onChanged: (v) => setState(() => _lane = v!),
                  ),
                TextFormField(
                  key: const ValueKey('guided-title'),
                  controller: _title,
                  maxLength: 200,
                  decoration: InputDecoration(labelText: l.nameLabel),
                  validator: (text) {
                    if (text == null || text.trim().isEmpty) {
                      return l.nameIsRequired;
                    }
                    for (final lane
                        in _lane == 'both' ? ['morning', 'evening'] : [_lane]) {
                      if (widget.collections[lane]!.any(
                        (e) =>
                            e.id != widget.entry?.id &&
                            e.title.trim().toLowerCase() ==
                                text.trim().toLowerCase(),
                      )) {
                        return l.zikrAlreadyExists;
                      }
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: const ValueKey('guided-arabic'),
                  controller: _arabic,
                  maxLength: 10000,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(labelText: l.arabicText),
                ),
                TextFormField(
                  key: const ValueKey('guided-meaning'),
                  controller: _meaning,
                  maxLength: 10000,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l.meaning),
                ),
                TextFormField(
                  key: const ValueKey('guided-reference'),
                  controller: _reference,
                  maxLength: 1000,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l.sourceOptional),
                ),
                TextFormField(
                  key: const ValueKey('guided-transliteration'),
                  controller: _transliteration,
                  maxLength: 10000,
                  maxLines: 3,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: l.transliterationOptional,
                  ),
                ),
                TextFormField(
                  key: const ValueKey('guided-urdu'),
                  controller: _urdu,
                  maxLength: 10000,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(labelText: l.urduMeaningOptional),
                ),
                TextFormField(
                  key: const ValueKey('guided-target'),
                  controller: _target,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l.repetitionTarget),
                  validator: (text) {
                    final n = int.tryParse(text ?? '');
                    return n == null || n < 1 || n > 1000000
                        ? l.validGoals
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            final entry = AdhkarEntry(
              _title.text.trim(),
              _arabic.text.trim(),
              _meaning.text.trim(),
              _reference.text.trim(),
              int.parse(_target.text),
              transliteration: _transliteration.text.trim(),
              urduMeaning: _urdu.text.trim(),
              id:
                  widget.entry?.id ??
                  'custom_${DateTime.now().microsecondsSinceEpoch}',
            );
            Navigator.pop(context, (entry, _lane));
          },
          child: Text(widget.entry == null ? l.add : l.saveDhikr),
        ),
      ],
    );
  }
}
