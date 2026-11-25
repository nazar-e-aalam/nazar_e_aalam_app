import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../../../controller/namaz_controller.dart';
import '../../../../data/model/response/namaz_model.dart';
import 'namaz_labels.dart';

class NamazSectionRenderer extends StatelessWidget {
  final NamazSection section;
  final NamazItem item;
  final String lang;
  final bool modern;
  final NamazController controller;
  const NamazSectionRenderer({
    super.key,
    required this.section,
    required this.item,
    required this.lang,
    required this.modern,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) => Obx(() {
    final theme = Theme.of(context);
    final s = section;
    final title = s.text('title', lang);
    final body = s.text('text', lang);
    final translation = s.text('translations', lang);
    final pronunciation = s.text('transliterations', lang);
    final counts = <String, String>{
      'repeat_count': 'repeat',
      'minimum_repeat_count': 'min',
      'maximum_repeat_count': 'max',
      'rakat_count': 'rakat',
      'takbir_count': 'takbir',
    };
    final refs = item.references.where((r) => s.referenceIds.contains(r['id']));
    final caution = s.type == 'warning' || s.type == 'note';
    final children = <Widget>[
      if (title.isNotEmpty)
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      if (body.isNotEmpty)
        SelectableText(
          body,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.65),
        ),
      if (s.arabic.isNotEmpty)
        Directionality(
          textDirection: TextDirection.rtl,
          child: SelectableText(
            s.arabic,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: controller.arabicSize.value,
              height: 1.9,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      if (lang != 'ar' &&
          controller.showTransliteration.value &&
          pronunciation.isNotEmpty)
        SelectableText(
          pronunciation,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      if (controller.showTranslation.value &&
          translation.isNotEmpty &&
          translation != s.arabic &&
          translation != body)
        SelectableText(
          translation,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final entry in counts.entries)
            if (s.count(entry.key) != null)
              Chip(
                label: Text('${nl(entry.value, lang)}: ${s.count(entry.key)}'),
              ),
          if ((s.data['rakat_numbers'] as List? ?? []).isNotEmpty)
            Chip(
              label: Text(
                '${nl('rakat', lang)}: ${(s.data['rakat_numbers'] as List).join(', ')}',
              ),
            ),
        ],
      ),
      for (final condition in s.conditions(lang))
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(condition)),
          ],
        ),
      if (s.externalTarget != null)
        Text(
          nl('missing', lang),
          style: TextStyle(color: theme.colorScheme.error),
        ),
      if (refs.isNotEmpty)
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(nl('references', lang)),
          children: [
            for (final ref in refs)
              ListTile(
                title: Text(
                  (ref['book'] ?? ref['original_citation']).toString(),
                ),
                subtitle: Text(
                  [
                    ref['original_citation'],
                    ref['page'],
                    ref['hadith_number'],
                    ref['verification_status'],
                    ref['notes'],
                  ].where((v) => v != null).join(' • '),
                ),
              ),
          ],
        ),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: caution
            ? theme.colorScheme.errorContainer.withValues(alpha: .35)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(modern ? 20 : 4),
        border: Border.all(color: theme.dividerColor.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children)
            Padding(padding: const EdgeInsets.only(bottom: 6), child: child),
        ],
      ),
    );
  });
}
