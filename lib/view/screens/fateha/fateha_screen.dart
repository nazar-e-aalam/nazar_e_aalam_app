import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../../data/model/fateha_model.dart';
import '../../../data/repository/fateha_repository.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

enum FatehaLayout { classic, modern }

class FatehaScreen extends StatefulWidget {
  final FatehaLayout layout;
  final bool appBackButton;
  const FatehaScreen({
    super.key,
    this.layout = FatehaLayout.classic,
    this.appBackButton = true,
  });
  @override
  State<FatehaScreen> createState() => _FatehaScreenState();
}

class _FatehaScreenState extends State<FatehaScreen> {
  late Future<FatehaDocument> _future;
  final _scroll = ScrollController();
  final _anchors = <int, GlobalKey>{};
  double _scale = 1, _progress = 0;
  String get language => switch (Get.locale?.languageCode) {
    'guj' => 'gu',
    'hin' => 'hi',
    final String code => code,
    _ => 'gu',
  };
  bool get modern => widget.layout == FatehaLayout.modern;
  String tr(List<String> values) =>
      values[const {
            'en': 0,
            'hi': 1,
            'gu': 2,
            'ur': 3,
            'ar': 4,
            'sw': 5,
          }[language] ??
          0];
  @override
  void initState() {
    super.initState();
    _future = FatehaRepository().load();
    _scroll.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final next = max > 0
        ? (_scroll.offset / max).clamp(0.0, 1.0).toDouble()
        : 0.0;
    if ((next - _progress).abs() > .005 && mounted) {
      setState(() => _progress = next);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _retry() {
    FatehaRepository.clearCache();
    setState(() {
      _future = FatehaRepository().load();
      _progress = 0;
    });
  }

  Future<void> _contents(FatehaDocument doc) async {
    final index = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: doc.sections.length,
          itemBuilder: (_, i) => ListTile(
            leading: Text('${i + 1}'),
            title: Text(
              doc.sections[i].localizedTitle(language, doc.defaultLanguage),
            ),
            onTap: () => Navigator.pop(ctx, i),
          ),
        ),
      ),
    );
    if (!mounted || index == null) return;
    final target = _anchors[index]?.currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonExist: widget.appBackButton,
        title: tr([
          'Fateha Ka Tarika',
          'फ़ातिहा का तरीक़ा',
          'ફાતિહે કા તરીકા',
          'فاتحہ کا طریقہ',
          'طريقة الفاتحة',
          'Utaratibu wa Fatiha',
        ]),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<FatehaDocument>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: c.error, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        tr([
                          'Unable to load Fateha',
                          'फ़ातिहा लोड नहीं हुई',
                          'ફાતિહા લોડ થઈ નથી',
                          'فاتحہ لوڈ نہیں ہو سکی',
                          'تعذر تحميل الفاتحة',
                          'Imeshindikana kupakia Fatiha',
                        ]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _retry,
                        child: Text(
                          tr([
                            'Retry',
                            'फिर कोशिश करें',
                            'ફરી પ્રયાસ કરો',
                            'دوبارہ کوشش کریں',
                            'إعادة المحاولة',
                            'Jaribu tena',
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final doc = snapshot.requireData;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: tr([
                          'Contents',
                          'विषय सूची',
                          'વિષયસૂચિ',
                          'فہرست',
                          'المحتويات',
                          'Yaliyomo',
                        ]),
                        onPressed: () => _contents(doc),
                        icon: const Icon(Icons.format_list_numbered),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: tr([
                          'Smaller text',
                          'छोटा अक्षर',
                          'નાના અક્ષર',
                          'چھوٹا متن',
                          'تصغير الخط',
                          'Maandishi madogo',
                        ]),
                        onPressed: _scale <= .8
                            ? null
                            : () => setState(
                                () => _scale = (_scale - .1)
                                    .clamp(.8, 1.8)
                                    .toDouble(),
                              ),
                        icon: const Icon(Icons.text_decrease),
                      ),
                      Text('${(_scale * 100).round()}%'),
                      IconButton(
                        tooltip: tr([
                          'Larger text',
                          'बड़ा अक्षर',
                          'મોટા અક્ષર',
                          'بڑا متن',
                          'تكبير الخط',
                          'Maandishi makubwa',
                        ]),
                        onPressed: _scale >= 1.8
                            ? null
                            : () => setState(
                                () => _scale = (_scale + .1)
                                    .clamp(.8, 1.8)
                                    .toDouble(),
                              ),
                        icon: const Icon(Icons.text_increase),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(value: _progress, minHeight: 2),
                Expanded(
                  child: SelectionArea(
                    child: SingleChildScrollView(
                      controller: _scroll,
                      padding: EdgeInsets.fromLTRB(
                        modern ? 16 : 12,
                        16,
                        modern ? 16 : 12,
                        28,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < doc.sections.length; i++)
                                Container(
                                  key: _anchors.putIfAbsent(
                                    i,
                                    () => GlobalKey(),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: EdgeInsets.all(modern ? 18 : 8),
                                  decoration: modern
                                      ? BoxDecoration(
                                          color: c.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: c.outlineVariant,
                                          ),
                                        )
                                      : null,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: c.outlineVariant,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              '${i + 1}',
                                              style: TextStyle(
                                                color: c.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: c.outlineVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        doc.sections[i].localizedTitle(
                                          language,
                                          doc.defaultLanguage,
                                        ),
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              color: c.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 21 * _scale,
                                            ),
                                      ),
                                      const SizedBox(height: 18),
                                      for (final item in doc.sections[i].items)
                                        _FatehaItemView(
                                          item: item,
                                          language: language,
                                          fallback: doc.defaultLanguage,
                                          scale: _scale,
                                          modern: modern,
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FatehaItemView extends StatelessWidget {
  final FatehaItem item;
  final String language, fallback;
  final double scale;
  final bool modern;
  const _FatehaItemView({
    required this.item,
    required this.language,
    required this.fallback,
    required this.scale,
    required this.modern,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    final value = item.localizedText(language, fallback);
    final arabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    final letters = RegExp(r'[A-Za-z\u0900-\u097F\u0A80-\u0AFF]');
    final rtl =
        arabic.hasMatch(value) && !letters.hasMatch(value) ||
        language == 'ar' ||
        language == 'ur';
    final heading = item.type == 'heading';
    final reference = item.type == 'reference';
    final instruction = item.type == 'instruction';
    final separator = item.type == 'separator';
    final size = separator
        ? 14.0
        : reference
        ? 14.0
        : instruction
        ? 16.0
        : heading
        ? 19.0
        : rtl
        ? 25.0
        : 19.0;
    final text = Text(
      value,
      textAlign: instruction || reference ? TextAlign.start : TextAlign.center,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: size * scale,
        height: rtl ? 2.0 : 1.8,
        fontWeight: heading || instruction ? FontWeight.w600 : FontWeight.w400,
        color: heading || instruction || separator
            ? c.primary
            : reference
            ? c.onSurfaceVariant
            : c.onSurface,
        fontStyle: reference ? FontStyle.italic : FontStyle.normal,
        fontFamilyFallback: const [
          'Noto Naskh Arabic',
          'Noto Sans Arabic',
          'Noto Sans Gujarati',
          'Noto Sans Devanagari',
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: separator ? 12 : 18),
      child: instruction && modern
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.primaryContainer.withValues(alpha: .35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: text,
            )
          : text,
    );
  }
}
