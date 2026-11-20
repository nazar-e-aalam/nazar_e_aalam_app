// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/model/fateha_model.dart';
import '../../../data/repository/fateha_repository.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

enum FatehaLayout { classic, modern }

/// Works standalone. Pass layout: FatehaLayout.modern for the modern appearance.
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
  @override
  void initState() {
    super.initState();
    _future = FatehaRepository().load();
  }

  void _retry() {
    FatehaRepository.clearCache();
    setState(() {
      _future = FatehaRepository().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final modern = widget.layout == FatehaLayout.modern;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final language = Get.locale?.languageCode ?? 'gu';
    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonExist: widget.appBackButton,
        title: fatehaLocalize(
            const {
              'en': 'Fateha Ka Tarika',
              'gu': 'ફાતિહે કા તરીકા',
              'hi': 'फ़ातिहा का तरीक़ा',
              'sw': 'Utaratibu wa Fatiha',
              'ar': 'طريقة الفاتحة',
              'ur': 'فاتحہ کا طریقہ',
            },
            language,
            'gu',
        ),
      ),
      body: FutureBuilder<FatehaDocument>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Unable to load Fateha: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
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
              padding: EdgeInsets.symmetric(
                horizontal: modern ? 16 : 12,
                vertical: 16,
              ),
              itemCount: document.sections.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox.shrink();
                  // return Padding(
                  //   padding: const EdgeInsets.only(bottom: 20, top: 8),
                  //   child: Column(
                  //     children: [
                  //       // Icon(
                  //       //   Icons.auto_stories_rounded,
                  //       //   color: accent,
                  //       //   size: 36,
                  //       // ),
                  //       // const SizedBox(height: 10),
                  //       // Text(
                  //       //   document.localizedTitle(language),
                  //       //   textAlign: TextAlign.center,
                  //       //   style: theme.textTheme.headlineSmall?.copyWith(
                  //       //     fontWeight: FontWeight.bold,
                  //       //   ),
                  //       // ),
                  //     ],
                  //   ),
                  // );
                }
                final section = document.sections[index - 1];
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      section.localizedTitle(
                        language,
                        document.defaultLanguage,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final item in section.items)
                      _FatehaItemView(
                        item: item,
                        language: language,
                        fallback: document.defaultLanguage,
                        modern: modern,
                      ),
                  ],
                );
                if (modern) {
                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: .4,
                        ),
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: content,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: content,
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

class _FatehaItemView extends StatelessWidget {
  final FatehaItem item;
  final String language;
  final String fallback;
  final bool modern;
  const _FatehaItemView({
    required this.item,
    required this.language,
    required this.fallback,
    required this.modern,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final content = item.localizedText(language, fallback);
    final rtl = language == 'ar' || language == 'ur';
    if (item.type == 'separator') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(color: accent.withValues(alpha: .65), fontSize: 15),
        ),
      );
    }
    if (item.type == 'heading') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          content,
          textAlign: TextAlign.center,
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
      );
    }
    if (item.type == 'reference' || item.type == 'instruction') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          content,
          textAlign: TextAlign.center,
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: item.type == 'instruction'
                ? accent
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: item.type == 'instruction'
                ? FontWeight.w700
                : FontWeight.w400,
            fontStyle: item.type == 'reference'
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
      );
    }
    // All original recitations, duas and durood remain verbatim from the JSON.
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        content,
        textAlign: TextAlign.center,
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: language == 'ar' ? 23 : 18,
          height: language == 'ar' || language == 'ur' ? 2 : 1.75,
          fontWeight: modern ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}
