// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/dua_book_controller.dart';
import '../../../../data/model/dua_book_model.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'modern_dua_book_detail_screen.dart';
import '../../../../theme/light_theme.dart';

class ModernDuaBookScreen extends StatefulWidget {
  final bool? appBackButton;
  const ModernDuaBookScreen({super.key, this.appBackButton});
  @override
  State<ModernDuaBookScreen> createState() => _ModernDuaBookScreenState();
}

class _ModernDuaBookScreenState extends State<ModernDuaBookScreen> {
  final c = DuaBookController();
  final search = TextEditingController();
  String query = '';
  bool saved = false;
  static const accent = Color(0xffB95124);
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
            ModernDuaBookDetailScreen(controller: c, section: s, lang: lang),
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
    final dark = t.brightness == Brightness.dark;
    final ink = dark ? const Color(0xffFFB68D) : accent;
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
      backgroundColor: dark
          ? t.scaffoldBackgroundColor
          : const Color(0xffFFF8F3),
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
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        colors: [AppColor.primaryColor, AppColor.goldColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'THE DUA COLLECTION',
                                style: TextStyle(
                                  color: Colors.white70,
                                  letterSpacing: 1.4,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          book.title(lang),
                          textDirection: duaDirection(lang),
                          style: t.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${book.categories.length} chapters  •  ${sections.length} sections',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (sections.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: accent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () =>
                                  open(sections[last < 0 ? 0 : last], lang),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(
                                last < 0 ? 'Start reading' : 'Continue reading',
                              ),
                            ),
                          ),
                          if (last >= 0) ...[
                            const SizedBox(height: 12),
                            Text(
                              sections[last].title(lang),
                              textDirection: duaDirection(lang),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (last + 1) / sections.length,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Section ${last + 1} of ${sections.length}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
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
                      Material(
                        color: t.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: ink.withValues(alpha: .10),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      '${entry.key + 1}'.padLeft(2, '0'),
                                      style: TextStyle(
                                        color: ink,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.value.title(lang),
                                          textDirection: duaDirection(lang),
                                          style: t.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        if (entry.value
                                            .description(lang)
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 5),
                                          Text(
                                            entry.value.description(lang),
                                            textDirection: duaDirection(lang),
                                            style: t.textTheme.bodySmall,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              for (final s in entry.value.sections)
                                sectionTile(s, lang, ink),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
