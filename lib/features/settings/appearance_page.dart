import 'package:flutter/material.dart';
import '../../core/services/adhkar_service.dart';
import '../../core/services/locale_service.dart';
import '../../core/services/reading_preferences.dart';
import '../../core/services/theme_service.dart';
import '../../generated/app_localizations.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});
  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  bool _loading = true, _saving = false;
  double _arabic = 26, _meaning = 16;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ReadingPreferences.instance.load();
    if (mounted)
      setState(() {
        _arabic = ReadingPreferences.instance.arabicSize;
        _meaning = ReadingPreferences.instance.meaningSize;
        _loading = false;
      });
  }

  Future<void> _apply(Future<void> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await action();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted)
        setState(() {
          _arabic = ReadingPreferences.instance.arabicSize;
          _meaning = ReadingPreferences.instance.meaningSize;
          _saving = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      ReadingPreferences.instance,
      LocaleService.instance,
      ThemeService.instance,
    ]),
    builder: (context, _) {
      final l = AppLocalizations.of(context)!;
      final reading = ReadingPreferences.instance;
      final preview = adhkarEntries[3];
      final useUrdu = reading.useUrdu(
        Localizations.localeOf(context).languageCode,
      );
      return Scaffold(
        appBar: AppBar(title: Text(l.appearance)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'appearance-language-${LocaleService.instance.locale.languageCode}',
                        ),
                        initialValue:
                            LocaleService.instance.locale.languageCode,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l.changeLanguage,
                        ),
                        items: [
                          DropdownMenuItem(value: 'en', child: Text(l.english)),
                          DropdownMenuItem(value: 'ar', child: Text(l.arabic)),
                          DropdownMenuItem(value: 'ur', child: Text(l.urdu)),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) => _apply(
                                () => LocaleService.instance.setLocale(
                                  Locale(value!),
                                ),
                              ),
                      ),
                      SwitchListTile(
                        key: const ValueKey('settings-theme'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.darkMode),
                        value: ThemeService.instance.isDarkMode,
                        onChanged: _saving
                            ? null
                            : (value) => _apply(
                                () => ThemeService.instance.setTheme(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                ),
                              ),
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        '${l.arabicTextSize}: ${_arabic.round()}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        key: const ValueKey('arabic-size-slider'),
                        value: _arabic,
                        min: 20,
                        max: 44,
                        divisions: 24,
                        label: '${_arabic.round()}',
                        onChanged: _saving
                            ? null
                            : (v) => setState(() => _arabic = v),
                        onChangeEnd: (v) =>
                            _apply(() => reading.save(arabicSize: v)),
                      ),
                      Text(
                        '${l.meaningTextSize}: ${_meaning.round()}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        key: const ValueKey('meaning-size-slider'),
                        value: _meaning,
                        min: 12,
                        max: 26,
                        divisions: 14,
                        label: '${_meaning.round()}',
                        onChanged: _saving
                            ? null
                            : (v) => setState(() => _meaning = v),
                        onChangeEnd: (v) =>
                            _apply(() => reading.save(meaningSize: v)),
                      ),
                      SwitchListTile(
                        key: const ValueKey('show-transliteration'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.showTransliteration),
                        value: reading.showTransliteration,
                        onChanged: _saving
                            ? null
                            : (value) => _apply(
                                () => reading.save(showTransliteration: value),
                              ),
                      ),
                      DropdownButtonFormField<String>(
                        key: const ValueKey('meaning-language'),
                        initialValue: reading.meaningLanguage,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l.meaningLanguage,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'auto',
                            child: Text(l.followAppLanguage),
                          ),
                          DropdownMenuItem(value: 'en', child: Text(l.english)),
                          DropdownMenuItem(value: 'ur', child: Text(l.urdu)),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) => _apply(
                                () => reading.save(meaningLanguage: value),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.meaningFallbackExplanation,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l.readingPreview,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                preview.arabic,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: _arabic,
                                  height: 1.8,
                                ),
                              ),
                              if (reading.showTransliteration)
                                Text(
                                  preview.transliteration,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(fontSize: _meaning),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                useUrdu
                                    ? preview.urduMeaning
                                    : preview.translation,
                                textDirection: useUrdu
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                style: TextStyle(fontSize: _meaning),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    },
  );
}
