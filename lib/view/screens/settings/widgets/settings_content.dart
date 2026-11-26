import 'dart:convert';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'settings_actions.dart';

class SettingsContent extends StatefulWidget {
  final String module;
  final bool modern;
  const SettingsContent({
    super.key,
    required this.module,
    required this.modern,
  });
  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  static const paths = {
    'nasihat': 'assets/settings.json',
    'privacy_policy': 'assets/privacy.json',
    'about_us': 'assets/about.json',
  };
  late Future<Map<String, dynamic>> data = load();
  Future<Map<String, dynamic>> load() async {
    final path = paths[widget.module];
    if (path == null) {
      throw FormatException('Unknown document: ${widget.module}');
    }
    final root = jsonDecode(await rootBundle.loadString(path));
    if (root is! Map) throw const FormatException('Expected JSON object');
    final value = root[widget.module] ?? root;
    if (value is! Map) throw const FormatException('Invalid document');
    final result = Map<String, dynamic>.from(value);
    if (result['sections'] is! List &&
        result['items'] is! List &&
        result['text'] == null &&
        result['content'] == null) {
      throw const FormatException('Missing document content');
    }
    return result;
  }

  String local(dynamic value, String lang) {
    if (value is String) return value;
    if (value is Map) return (value[lang] ?? value['en'] ?? '').toString();
    return '';
  }

  List<Map> ordered(dynamic value) {
    if (value is! List) return [];
    final list = value.whereType<Map>().toList();
    if (list.every((e) => e['order'] is num)) {
      list.sort((a, b) => (a['order'] as num).compareTo(b['order'] as num));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final code =
        Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final lang = {'hin': 'hi', 'guj': 'gu', 'ara': 'ar'}[code] ?? code;
    final direction = ['ar', 'ur'].contains(lang)
        ? TextDirection.rtl
        : TextDirection.ltr;
    final fallback =
        {
          'nasihat': 'Nasihat',
          'about_us': 'About us',
          'privacy_policy': 'Privacy policy',
        }[widget.module] ??
        widget.module.tr;
    final accent = t.primaryColor;
    Widget paragraph(String text) => SelectableText(
      text,
      textDirection: direction,
      textAlign: TextAlign.start,
      style: t.textTheme.bodyLarge?.copyWith(height: 1.75),
    );
    Widget panel(Widget child, {bool featured = false}) => Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: widget.modern ? 0 : 1,
      color: featured ? accent.withValues(alpha: .09) : t.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.modern ? 22 : 8),
        side: widget.modern
            ? BorderSide(color: t.dividerColor.withValues(alpha: .18))
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.modern ? 20 : 16),
        child: child,
      ),
    );
    Widget block(Map item) {
      final text = local(item['text'], lang);
      switch (item['type']) {
        case 'bullet_list':
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry
                  in (item['items'] is List ? item['items'] as List : const []))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 9),
                        child: Icon(Icons.circle, size: 6, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: paragraph(local(entry, lang))),
                    ],
                  ),
                ),
            ],
          );
        case 'link':
        case 'email':
          final url = item['url']?.toString() ?? '';
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: url.isEmpty ? null : () => SettingsActions.open(url),
              icon: Icon(
                item['type'] == 'email'
                    ? Icons.mail_outline
                    : Icons.open_in_new,
                size: 18,
              ),
              label: Text(text.isEmpty ? url : text),
            ),
          );
        default:
          return text.isEmpty ? const SizedBox.shrink() : paragraph(text);
      }
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: data,
      builder: (context, snapshot) {
        final d = snapshot.data;
        final title = local(d?['title'], lang);
        return Scaffold(
          appBar: CustomAppBar(
            title: title.isEmpty ? fallback.tr : title.tr,
            isBackButtonExist: true,
          ),
          body: SafeArea(
            top: false,
            child: snapshot.connectionState != ConnectionState.done
                ? const Center(child: CircularProgressIndicator())
                : snapshot.hasError || d == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Content unavailable'.tr),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => setState(() => data = load()),
                            child: Text('Retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  )
                : Directionality(
                    textDirection: direction,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                      children: [
                        if (widget.module == 'about_us')
                          panel(
                            Column(
                              children: [
                                Icon(
                                  Icons.auto_stories_rounded,
                                  size: 52,
                                  color: accent,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nazar E Aalam',
                                  textAlign: TextAlign.center,
                                  style: t.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (local(d['tagline'], lang).isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    local(d['tagline'], lang),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                            featured: widget.modern,
                          ),
                        if (widget.module == 'privacy_policy' &&
                            d['metadata'] is Map &&
                            d['metadata']['effective_date'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              '${'Effective date'.tr}: ${d['metadata']['effective_date']}',
                              style: t.textTheme.bodySmall,
                            ),
                          ),
                        if (local(d['text'] ?? d['content'], lang).isNotEmpty)
                          panel(
                            paragraph(local(d['text'] ?? d['content'], lang)),
                          ),
                        for (final entry in ordered(d['items']).asMap().entries)
                          panel(
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: accent.withValues(
                                    alpha: .12,
                                  ),
                                  foregroundColor: accent,
                                  child: Text('${entry.key + 1}'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: block(entry.value)),
                              ],
                            ),
                          ),
                        for (final section in ordered(d['sections']))
                          panel(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  local(section['title'], lang),
                                  style: t.textTheme.titleLarge?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                for (final item in ordered(section['items']))
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: block(item),
                                  ),
                              ],
                            ),
                          ),
                        if (d['closing_dua'] is Map)
                          panel(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(Icons.favorite_border, color: accent),
                                const SizedBox(height: 12),
                                paragraph(
                                  local(d['closing_dua']['text'], lang),
                                ),
                              ],
                            ),
                            featured: true,
                          ),
                        if (ordered(d['items']).isEmpty &&
                            ordered(d['sections']).isEmpty &&
                            local(d['text'] ?? d['content'], lang).isEmpty &&
                            d['closing_dua'] == null)
                          Center(child: Text('Content unavailable'.tr)),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
