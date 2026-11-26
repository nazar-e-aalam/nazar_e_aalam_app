// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../controller/dua_book_controller.dart';
import '../../../data/model/dua_book_model.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

class DuaBookDetailScreen extends StatefulWidget {
  final DuaBookController controller;
  final DuaSection section;
  final String lang;
  final bool modern;
  const DuaBookDetailScreen({
    super.key,
    required this.controller,
    required this.section,
    required this.lang,
    this.modern = false,
  });
  @override
  State<DuaBookDetailScreen> createState() => _DuaBookDetailScreenState();
}

class _DuaBookDetailScreenState extends State<DuaBookDetailScreen> {
  late DuaSection section = widget.section;
  final scroll = ScrollController();
  final counts = <String, int>{};
  DuaBookController get c => widget.controller;
  String get lang => widget.lang;
  Color get ink => Theme.of(context).colorScheme.primary;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) c.visit(section.id);
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void open(DuaSection next) {
    setState(() => section = next);
    c.visit(next.id);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void contents(List<DuaSection> sections) async {
    final next = await showModalBottomSheet<DuaSection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: .75,
          child: Column(
            children: [
              Text('Contents', style: Theme.of(sheet).textTheme.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: sections.length,
                  itemBuilder: (_, i) => ListTile(
                    selected: sections[i].id == section.id,
                    leading: Text('${i + 1}'),
                    title: Text(
                      sections[i].title(lang),
                      textDirection: duaDirection(lang),
                    ),
                    onTap: () => Navigator.pop(sheet, sections[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && next != null) open(next);
  }

  void settings() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: ListenableBuilder(
        listenable: c,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reading preferences',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              Text('Arabic font size · ${c.fontSize.round()}'),
              Slider(
                value: c.fontSize.clamp(22, 48).toDouble(),
                min: 22,
                max: 48,
                onChanged: (v) => c.settings(size: v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Meaning'),
                value: c.translation,
                onChanged: (v) => c.settings(meaning: v),
              ),
              if (lang != 'ar')
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pronunciation'),
                  value: c.transliteration,
                  onChanged: (v) => c.settings(pronunciation: v),
                ),
            ],
          ),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (context, _) {
      final t = Theme.of(context);
      final all = c.book?.sections ?? <DuaSection>[];
      final sections = all.any((s) => s.id == section.id) ? all : [section];
      final index = sections.indexWhere((s) => s.id == section.id);
      return Scaffold(
        appBar: CustomAppBar(
          isBackButtonExist: true,
          title: 'Dua Book',
          actions: [
            IconButton(
              tooltip: 'Contents',
              onPressed: () => contents(sections),
              icon: const Icon(Icons.format_list_bulleted_rounded),
            ),
            IconButton(
              tooltip: 'Reading preferences',
              onPressed: settings,
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        backgroundColor: t.scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (index + 1) / sections.length,
                    color: ink,
                    backgroundColor: ink.withValues(alpha: .12),
                    minHeight: 3,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  itemCount: section.items.length + 1,
                  itemBuilder: (context, i) => i == 0
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SECTION ${index + 1} / ${sections.length}',
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                section.title(lang),
                                textDirection: duaDirection(lang),
                                style: t.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                children: [
                                  FilterChip(
                                    label: const Text('Meaning'),
                                    selected: c.translation,
                                    onSelected: (v) => c.settings(meaning: v),
                                  ),
                                  if (lang != 'ar')
                                    FilterChip(
                                      label: const Text('Pronunciation'),
                                      selected: c.transliteration,
                                      onSelected: (v) =>
                                          c.settings(pronunciation: v),
                                    ),
                                ],
                              ),
                              const Divider(height: 28),
                              if (section.items.isEmpty)
                                const Text('No entries in this section.'),
                            ],
                          ),
                        )
                      : render(section.items[i - 1], t),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Material(
          color: t.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  IconButton.outlined(
                    tooltip: 'Previous section',
                    onPressed: index > 0
                        ? () => open(sections[index - 1])
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '${index + 1} of ${sections.length}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: index + 1 < sections.length
                        ? () => open(sections[index + 1])
                        : () => Navigator.maybePop(context),
                    icon: Icon(
                      index + 1 < sections.length
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(index + 1 < sections.length ? 'Next' : 'Done'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  Widget bookmark(DuaItem item) => IconButton(
    tooltip: c.bookmarks.contains(item.id)
        ? 'Remove bookmark'
        : 'Save bookmark',
    onPressed: () => c.toggle(item.id),
    icon: Icon(
      c.bookmarks.contains(item.id)
          ? Icons.bookmark_rounded
          : Icons.bookmark_border_rounded,
      color: ink,
    ),
  );
  Widget render(DuaItem item, ThemeData t) {
    if (item.type == 'separator') return const Divider(height: 30);
    final title = item.title(lang);
    final text = item.text(lang);
    final heading = item.type == 'heading' || item.type == 'subheading';
    final repeat = item.repeat;
    final count = counts[item.id] ?? 0;
    final body = t.textTheme.bodyLarge?.copyWith(height: 1.8);
    if (!item.recitation) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                text.isNotEmpty ? text : title,
                textDirection: duaDirection(lang),
                style: heading
                    ? t.textTheme.titleLarge?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      )
                    : body,
              ),
            ),
            bookmark(item),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.isEmpty ? 'Recitation' : title,
                      textDirection: duaDirection(lang),
                      style: t.textTheme.titleMedium?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  bookmark(item),
                ],
              ),
              if (item.arabic.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                SelectableText(
                  item.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: c.fontSize,
                    height: 2,
                    color: t.colorScheme.onSurface,
                  ),
                ),
              ],
              if ((c.transliteration || item.arabic.trim().isEmpty) &&
                  item.pronunciation(lang).isNotEmpty)
                readingBlock('Pronunciation', item.pronunciation(lang), body),
              if ((c.translation ||
                      item.arabic.trim().isEmpty &&
                          item.pronunciation(lang).isEmpty) &&
                  item.meaning(lang).isNotEmpty)
                readingBlock('Meaning', item.meaning(lang), body),
              if (repeat != null && repeat > 0) ...[
                const SizedBox(height: 20),
                Text('Repeat $repeat times', style: t.textTheme.labelLarge),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (count / repeat).clamp(0, 1).toDouble(),
                  color: ink,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => counts[item.id] = 0),
                      child: const Text('Reset'),
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: count < repeat
                          ? () => setState(() => counts[item.id] = count + 1)
                          : null,
                      icon: Icon(count >= repeat ? Icons.check : Icons.add),
                      label: Text('$count / $repeat'),
                    ),
                  ],
                ),
              ],
              if (item.data['references'] is List)
                for (final ref
                    in (item.data['references'] as List).whereType<Map>())
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${ref['source'] ?? ''} ${ref['reference_number'] ?? ''}'
                          .trim(),
                      style: t.textTheme.bodySmall,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget readingBlock(String label, String value, TextStyle? style) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 7),
        SelectableText(value, textDirection: duaDirection(lang), style: style),
      ],
    ),
  );
}
