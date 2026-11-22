// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../data/model/wazaif_data.dart';

class WazaifDetailScreen extends StatelessWidget {
  final Wazifa wazifa;
  final bool modern;
  const WazaifDetailScreen({super.key, required this.wazifa, required this.modern});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(wazifa.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: modern ? scheme.primaryContainer : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(modern ? 22 : 10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(wazifa.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textDirection: WazaifData.rtl ? TextDirection.rtl : TextDirection.ltr),
              if (wazifa.summary.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(wazifa.summary, textDirection: WazaifData.rtl ? TextDirection.rtl : TextDirection.ltr),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          for (final section in wazifa.sections)
            _SectionCard(key: ValueKey('${wazifa.id}_${section.id}'), section: section, modern: modern),
          if (wazifa.references.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('References', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final reference in wazifa.references)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_referenceText(reference))),
          ],
        ],
      ),
    );
  }

  String _referenceText(dynamic reference) {
    if (reference is String) return reference;
    if (reference is Map) {
      final map = Map<String, dynamic>.from(reference);
      final title = WazaifData.localized(_asMap(map['title']));
      final citation = map['citation'] ?? map['reference'] ?? map['source'] ?? '';
      return [title, citation.toString()].where((s) => s.isNotEmpty).join(' — ');
    }
    return reference.toString();
  }
}

Map<String, dynamic> _asMap(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : {};

class _SectionCard extends StatefulWidget {
  final WazifaSection section;
  final bool modern;
  const _SectionCard({super.key, required this.section, required this.modern});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  int progress = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.section;
    final scheme = Theme.of(context).colorScheme;
    final target = s.count;
    final canCount = s.type == 'recitation' && target != null && target > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.modern ? scheme.surfaceContainerLow : scheme.surface,
        borderRadius: BorderRadius.circular(widget.modern ? 20 : 10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(s.title.isNotEmpty ? s.title : _humanize(s.id),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
          if (target != null && target > 0)
            Chip(label: Text('× $target'), visualDensity: VisualDensity.compact),
        ]),
        if (s.arabic.isNotEmpty) ...[
          const SizedBox(height: 18),
          SelectableText(s.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 30, height: 1.9, color: scheme.onSurface)),
        ],
        if (s.transliteration.isNotEmpty) ...[
          const SizedBox(height: 14),
          SelectableText(s.transliteration, textAlign: TextAlign.center,
            textDirection: WazaifData.rtl ? TextDirection.rtl : TextDirection.ltr,
            style: Theme.of(context).textTheme.bodyLarge),
        ],
        if (s.translation.isNotEmpty && s.translation != s.arabic) ...[
          const SizedBox(height: 12),
          Text(s.translation, textAlign: TextAlign.center,
            textDirection: WazaifData.rtl ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
        if (s.content.isNotEmpty) ...[
          const SizedBox(height: 12),
          SelectableText(s.content,
            textDirection: WazaifData.rtl ? TextDirection.rtl : TextDirection.ltr),
        ],
        if (canCount) ...[
          const SizedBox(height: 18),
          LinearProgressIndicator(value: (progress / target).clamp(0.0, 1.0), minHeight: 5,
            borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 12),
          Row(children: [
            Text('$progress / $target', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(onPressed: progress == 0 ? null : () => setState(() => progress = 0),
              tooltip: 'Reset', icon: const Icon(Icons.refresh_rounded)),
            const SizedBox(width: 6),
            FilledButton.icon(
              onPressed: progress >= target ? null : () => setState(() => progress++),
              icon: const Icon(Icons.add_rounded), label: const Text('Count')),
          ]),
        ],
        if (s.referenceIds.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('References: ${s.referenceIds.join(', ')}',
            style: Theme.of(context).textTheme.bodySmall),
        ],
      ]),
    );
  }

  String _humanize(String value) {
    if (value.isEmpty) return widget.section.type.replaceAll('_', ' ');
    return value.replaceAll(RegExp(r'_\d+$'), '').replaceAll('_', ' ');
  }
}
