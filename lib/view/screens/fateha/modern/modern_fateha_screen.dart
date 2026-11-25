// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/model/fateha_model.dart';
import '../../../../data/repository/fateha_repository.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

class ModernFatehaScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernFatehaScreen({super.key, this.appBackButton = true});
  @override
  State<ModernFatehaScreen> createState() => _ModernFatehaScreenState();
}

class _ModernFatehaScreenState extends State<ModernFatehaScreen> {
  late Future<FatehaDocument> _future;
  final _scroll = ScrollController();
  final _anchors = <GlobalKey>[];
  double _scale = 1, _progress = 0;
  bool _showArabic = true;
  String get _lang => Get.locale?.languageCode ?? 'gu';
  String _label(List<String> values) {
    final index = ['en', 'hi', 'gu', 'ur', 'ar', 'sw'].indexOf(_lang);
    return values[index < 0 ? 0 : index];
  }

  @override
  void initState() {
    super.initState();
    _future = FatehaRepository().load();
    _scroll.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!_scroll.hasClients || !_scroll.position.hasContentDimensions) return;
    final max = _scroll.position.maxScrollExtent;
    final value = max <= 0
        ? 0.0
        : (_scroll.offset / max).clamp(0.0, 1.0).toDouble();
    if (mounted && (value - _progress).abs() > .005) {
      setState(() => _progress = value);
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
      _anchors.clear();
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
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(
              doc.sections[i].localizedTitle(_lang, doc.defaultLanguage),
            ),
            onTap: () => Navigator.pop(ctx, i),
          ),
        ),
      ),
    );
    if (!mounted || index == null || index >= _anchors.length) return;
    final target = _anchors[index].currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  TextStyle _reading(
    BuildContext context,
    String value, {
    bool arabic = false,
  }) {
    final rtl = arabic || _lang == 'ar' || _lang == 'ur';
    return (Theme.of(context).textTheme.bodyLarge ?? const TextStyle())
        .copyWith(
          fontSize:
              (arabic || _lang == 'ar'
                  ? 26
                  : _lang == 'ur'
                  ? 22
                  : 18) *
              _scale,
          height: rtl ? 2.1 : 1.8,
          fontWeight: FontWeight.w400,
          fontFamily: rtl
              ? null
              : Theme.of(context).textTheme.bodyLarge?.fontFamily,
          fontFamilyFallback: rtl
              ? const ['Noto Naskh Arabic', 'Noto Nastaliq Urdu', 'sans-serif']
              : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), c = theme.colorScheme;
    final rtl = _lang == 'ar' || _lang == 'ur';
    final title = _label([
      'Fateha Ka Tarika',
      'फ़ातिहा का तरीक़ा',
      'ફાતિહાનો તરીકો',
      'فاتحہ کا طریقہ',
      'طريقة الفاتحة',
      'Utaratibu wa Fatiha',
    ]);
    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonExist: widget.appBackButton,
        title: title,
      ),
      body: FutureBuilder<FatehaDocument>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    _label([
                      'Unable to load',
                      'लोड नहीं हुआ',
                      'લોડ થઈ શક્યું નથી',
                      'لوڈ نہیں ہو سکا',
                      'تعذر التحميل',
                      'Imeshindwa kupakia',
                    ]),
                  ),
                  FilledButton(
                    onPressed: _retry,
                    child: Text(
                      _label([
                        'Retry',
                        'पुनः प्रयास',
                        'ફરી પ્રયાસ',
                        'دوبارہ کوشش',
                        'إعادة المحاولة',
                        'Jaribu tena',
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }
          final doc = snapshot.requireData;
          while (_anchors.length < doc.sections.length) {
            _anchors.add(GlobalKey());
          }
          return Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 3,
                    backgroundColor: c.surfaceContainerHighest,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: _label([
                            'Contents',
                            'विषय सूची',
                            'અનુક્રમણિકા',
                            'فہرست',
                            'الفهرس',
                            'Yaliyomo',
                          ]),
                          onPressed: () => _contents(doc),
                          icon: const Icon(Icons.format_list_bulleted_rounded),
                        ),
                        const Spacer(),
                        IconButton(
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
                          onPressed: _scale >= 1.8
                              ? null
                              : () => setState(
                                  () => _scale = (_scale + .1)
                                      .clamp(.8, 1.8)
                                      .toDouble(),
                                ),
                          icon: const Icon(Icons.text_increase),
                        ),
                        if (_lang != 'ar')
                          IconButton(
                            tooltip: _label([
                              'Arabic text',
                              'अरबी पाठ',
                              'અરબી લખાણ',
                              'عربی متن',
                              'النص العربي',
                              'Maandishi ya Kiarabu',
                            ]),
                            onPressed: () =>
                                setState(() => _showArabic = !_showArabic),
                            icon: Icon(
                              _showArabic
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SelectionArea(
                      child: SingleChildScrollView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                gradient: LinearGradient(
                                  colors: [
                                    c.primary,
                                    c.primary.withValues(alpha: .82),
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.auto_stories_outlined,
                                    color: c.onPrimary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: c.onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${doc.sections.length} · ${(_progress * 100).round()}%',
                                    style: TextStyle(color: c.onPrimary),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _progress,
                                    color: c.onPrimary,
                                    backgroundColor: c.onPrimary.withValues(
                                      alpha: .25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            for (var i = 0; i < doc.sections.length; i++)
                              Container(
                                key: _anchors[i],
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: c.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: c.outlineVariant.withValues(
                                      alpha: .5,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: c.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${i + 1}'.padLeft(2, '0'),
                                            style: TextStyle(
                                              color: c.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            doc.sections[i].localizedTitle(
                                              _lang,
                                              doc.defaultLanguage,
                                            ),
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: c.primary,
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: MaterialLocalizations.of(
                                            context,
                                          ).copyButtonLabel,
                                          onPressed: () => Clipboard.setData(
                                            ClipboardData(
                                              text: doc.sections[i].items
                                                  .map(
                                                    (item) =>
                                                        item.localizedText(
                                                          _lang,
                                                          doc.defaultLanguage,
                                                        ),
                                                  )
                                                  .join('\n\n'),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.copy_rounded,
                                            size: 19,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Divider(color: c.outlineVariant),
                                    for (final item in doc.sections[i].items)
                                      _item(context, item, doc.defaultLanguage),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _item(BuildContext context, FatehaItem item, String fallback) {
    final c = Theme.of(context).colorScheme;
    final value = item.localizedText(_lang, fallback);
    final rtl = _lang == 'ar' || _lang == 'ur';
    if (item.type == 'separator') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.primary),
        ),
      );
    }
    if (item.type == 'heading' ||
        item.type == 'instruction' ||
        item.type == 'reference') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          value,
          textAlign: item.type == 'heading'
              ? TextAlign.center
              : TextAlign.start,
          style: _reading(context, value).copyWith(
            fontSize: (item.type == 'reference' ? 14 : 17) * _scale,
            color: item.type == 'reference' ? c.onSurfaceVariant : c.primary,
            fontWeight: item.type == 'reference'
                ? FontWeight.w400
                : FontWeight.w600,
          ),
        ),
      );
    }
    final arabic = item.localizedText('ar', fallback);
    final show =
        _showArabic &&
        _lang != 'ar' &&
        arabic != value &&
        RegExp(r'[\u0600-\u06FF]').hasMatch(arabic);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (show)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: c.primaryContainer.withValues(alpha: .35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: _reading(context, arabic, arabic: true),
              ),
            ),
          Text(
            value,
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: TextAlign.center,
            style: _reading(context, value),
          ),
        ],
      ),
    );
  }
}
