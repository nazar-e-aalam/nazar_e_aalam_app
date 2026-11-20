// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/kalima_model.dart';
import '../service/kalima_local_service.dart';

String kalimaLanguage() {
  final code = Get.locale?.languageCode ?? 'en';

  return const {'en', 'ar', 'hi', 'sw', 'ur'}.contains(code)
      ? code
      : 'en';
}

class KalimaListContent extends StatelessWidget {
  final bool modern;
  final void Function(KalimaModel kalima) onSelected;

  const KalimaListContent({
    super.key,
    required this.onSelected,
    this.modern = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<KalimaModel>>(
      future: KalimaLocalService.getKalimas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Unable to load Kalima: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final kalimas = snapshot.data!;
        final language = kalimaLanguage();
        final primary = Theme.of(context).primaryColor;
        final colorScheme = Theme.of(context).colorScheme;

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: kalimas.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final kalima = kalimas[index];

            return Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(
                modern ? 20 : 12,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  modern ? 20 : 12,
                ),
                onTap: () => onSelected(kalima),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      modern ? 20 : 12,
                    ),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          '${kalima.position}',
                          style: TextStyle(
                            color: primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          kalima.localizedTitle(language),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class KalimaDetailsContent extends StatelessWidget {
  final KalimaModel kalima;
  final bool modern;

  const KalimaDetailsContent({
    super.key,
    required this.kalima,
    this.modern = false,
  });

  @override
  Widget build(BuildContext context) {
    final language = kalimaLanguage();
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final colors = theme.colorScheme;
    final radius = modern ? 22.0 : 12.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            kalima.localizedTitle(language),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '﷽',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 44,
              color: primary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: primary.withValues(alpha: 0.18),
              ),
            ),
            child: SelectableText(
              kalima.arabicText,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 29,
                height: 2.0,
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: primary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _meaningLabel(language),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  kalima.localizedTranslation(language),
                  textDirection: const {'ar', 'ur'}
                          .contains(language)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.8,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _meaningLabel(String language) {
    switch (language) {
      case 'ar':
        return 'المعنى';
      case 'hi':
        return 'अर्थ';
      case 'sw':
        return 'Maana';
      case 'ur':
        return 'ترجمہ';
      default:
        return 'Meaning';
    }
  }
}
