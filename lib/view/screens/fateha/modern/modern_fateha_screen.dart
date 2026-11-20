// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/model/fateha_model.dart';
import '../../../../data/repository/fateha_repository.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

/// Dedicated modern reading layout. Uses the same JSON as the classic screen.
class ModernFatehaScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernFatehaScreen({super.key, this.appBackButton = true});

  @override
  State<ModernFatehaScreen> createState() => _ModernFatehaScreenState();
}

class _ModernFatehaScreenState extends State<ModernFatehaScreen> {
  late Future<FatehaDocument> _future;

  @override
  void initState() {
    super.initState();
    _future = FatehaRepository().load();
  }

  void _retry() {
    FatehaRepository.clearCache();
    final next = FatehaRepository().load();
    setState(() {
      _future = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Get.locale?.languageCode ?? 'gu';
    final rtl = language == 'ar' || language == 'ur';

    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonExist: widget.appBackButton,
        title: (fatehaLocalize(const {
          'en': 'Fateha Ka Tarika',
          'gu': 'ફાતિહે કા તરીકા',
          'hi': 'फ़ातिहा का तरीक़ा',
          'sw': 'Utaratibu wa Fatiha',
          'ar': 'طريقة الفاتحة',
          'ur': 'فاتحہ کا طریقہ',
        }, language, 'gu')),
      ),
      body: FutureBuilder<FatehaDocument>(
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
                    Text('Unable to load Fateha: ${snapshot.error}',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _retry, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final document = snapshot.requireData;
          return SelectionArea(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: document.sections.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 26),
                    child: Column(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 40, color: scheme.primary),
                        const SizedBox(height: 12),
                        Text(document.localizedTitle(language),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  );
                }
                final section = document.sections[index - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(section.localizedTitle(language, document.defaultLanguage),
                          textAlign: TextAlign.center,
                          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700, color: scheme.primary)),
                      const SizedBox(height: 18),
                      for (final item in section.items)
                        _ModernFatehaItem(
                          item: item,
                          language: language,
                          fallback: document.defaultLanguage,
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ModernFatehaItem extends StatelessWidget {
  final FatehaItem item;
  final String language;
  final String fallback;

  const _ModernFatehaItem({
    required this.item,
    required this.language,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final value = item.localizedText(language, fallback);
    final rtl = language == 'ar' || language == 'ur';
    final direction = rtl ? TextDirection.rtl : TextDirection.ltr;

    if (item.type == 'separator') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(value, textAlign: TextAlign.center,
            style: TextStyle(color: scheme.primary.withValues(alpha: 0.65), fontSize: 14)),
      );
    }

    if (item.type == 'heading') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(value, textAlign: TextAlign.center, textDirection: direction,
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: scheme.primary)),
      );
    }

    if (item.type == 'reference' || item.type == 'instruction') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(value, textAlign: TextAlign.center, textDirection: direction,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: item.type == 'instruction' ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: item.type == 'instruction' ? FontWeight.bold : FontWeight.normal,
              fontStyle: item.type == 'reference' ? FontStyle.italic : FontStyle.normal,
            )),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(value, textAlign: TextAlign.center, textDirection: direction,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: language == 'ar' ? 23 : 18,
            height: rtl ? 2 : 1.8,
            fontWeight: FontWeight.w500,
          )),
    );
  }
}
