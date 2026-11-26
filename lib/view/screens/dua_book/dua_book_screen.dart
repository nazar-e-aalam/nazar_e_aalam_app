// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/dua_book_controller.dart';
import '../../../data/model/dua_book_model.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'dua_book_detail_screen.dart';

class DuaBookScreen extends StatefulWidget {
  final bool? appBackButton;
  final bool modern;
  const DuaBookScreen({super.key, this.appBackButton, this.modern = false});
  @override
  State<DuaBookScreen> createState() => _DuaBookScreenState();
}

class _DuaBookScreenState extends State<DuaBookScreen> {
  final c = DuaBookController();
  final search = TextEditingController();
  String query = '';
  bool saved = false;
  Color get accent => Theme.of(context).colorScheme.primary;
  @override
  void initState() {
    super.initState();
    c.load();
  }

  @override
  void dispose() {
    search.dispose();
    c.dispose();
    super.dispose();
  }

  void open(DuaSection s, String lang) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DuaBookDetailScreen(controller: c, section: s, lang: lang),
      ),
    );
  }

  bool visible(DuaSection s, String lang) =>
      (!saved || s.items.any((i) => c.bookmarks.contains(i.id))) &&
      (query.isEmpty ||
          s.title(lang).toLowerCase().contains(query) ||
          s.items.any((i) => i.matches(query)));
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final lang = duaLanguage(
      Get.locale?.languageCode ?? Localizations.localeOf(context).languageCode,
    );
    final ink = t.colorScheme.primary;
    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonExist: widget.appBackButton ?? true,
        title: 'Dua Book',
        actions: [
          IconButton(
            tooltip: saved ? 'Show all chapters' : 'Bookmarks',
            onPressed: () => setState(() => saved = !saved),
            icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),
      backgroundColor: t.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            final book = c.book;
            if (c.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (book == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load Dua Book',
                        style: t.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Please try loading the book again.'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: c.load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final sections = book.sections;
            final last = sections.indexWhere((s) => s.id == c.lastSection);
            final matches = sections.where((s) => visible(s, lang)).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (!saved && query.isEmpty) ...[
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.menu_book_outlined, color: ink, size: 36),
                          const SizedBox(height: 10),
                          Text(
                            book.title(lang),
                            textDirection: duaDirection(lang),
                            textAlign: TextAlign.center,
                            style: t.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${book.categories.length} chapters • ${sections.length} sections',
                            textAlign: TextAlign.center,
                            style: t.textTheme.bodySmall,
                          ),
                          if (sections.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  open(sections[last < 0 ? 0 : last], lang),
                              icon: const Icon(Icons.auto_stories_outlined),
                              label: Text(
                                last < 0 ? 'Start reading' : 'Continue reading',
                              ),
                            ),
                            if (last >= 0)
                              Text(
                                sections[last].title(lang),
                                textDirection: duaDirection(lang),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: search,
                  onChanged: (v) =>
                      setState(() => query = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search duas and chapters',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              search.clear();
                              setState(() => query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: t.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All chapters'),
                      selected: !saved,
                      onSelected: (_) => setState(() => saved = false),
                    ),
                    ChoiceChip(
                      label: Text('Saved (${c.bookmarks.length})'),
                      selected: saved,
                      onSelected: (_) => setState(() => saved = true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  saved
                      ? 'Saved sections'
                      : query.isEmpty
                      ? 'Explore chapters'
                      : 'Search results',
                  style: t.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (matches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          saved ? Icons.bookmark_border : Icons.search_off,
                          size: 42,
                          color: ink,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          saved && query.isEmpty
                              ? 'No saved duas yet'
                              : 'No matching sections',
                        ),
                        TextButton(
                          onPressed: () {
                            search.clear();
                            setState(() {
                              query = '';
                              saved = false;
                            });
                          },
                          child: const Text('Browse all chapters'),
                        ),
                      ],
                    ),
                  )
                else if (saved || query.isNotEmpty)
                  ...matches.map((s) => sectionTile(s, lang, ink))
                else
                  for (final entry in book.categories.asMap().entries)
                    if (entry.value.sections.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 6),
                        child: Text(
                          entry.value.title(lang),
                          textDirection: duaDirection(lang),
                          style: t.textTheme.titleMedium?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      for (final s in entry.value.sections)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: sectionTile(s, lang, ink),
                        ),
                    ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget sectionTile(DuaSection s, String lang, Color ink) => Material(
    color: Colors.transparent,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(Icons.article_outlined, color: ink, size: 21),
      title: Text(s.title(lang), textDirection: duaDirection(lang)),
      subtitle: Text('${s.items.length} entries'),
      trailing: Icon(Icons.chevron_right_rounded, color: ink),
      onTap: () => open(s, lang),
    ),
  );
}
