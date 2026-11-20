
 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/data/model/mubarak_category_model.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

class MubarakCategoryDetailsScreen extends StatelessWidget {
  final MubarakCategory category;
  final bool modern;

  const MubarakCategoryDetailsScreen({
    super.key,
    required this.category,
    this.modern = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final language = Get.locale?.languageCode ?? 'gu';
    final primary = theme.primaryColor;
    final title = category.localizedTitle(language);
    final heading = category.localizedHeading(language);
    final rtl = language == 'ar' || language == 'ur';

    return Scaffold(
      backgroundColor: modern && !dark
          ? AppColorModern.scaffoldBackground
          : theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: title,
        isBackButtonExist: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          itemCount: category.entries.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _surface(
                  modern: modern,
                  dark: dark,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Text(
                          heading,
                          textAlign: TextAlign.center,
                          textDirection:
                              rtl ? TextDirection.rtl : null,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${category.entries.length}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final entry = category.entries[index - 1];
            final content = entry.localized(language);

            if (entry.isHeading) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _surface(
                  modern: modern,
                  dark: dark,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      content,
                      textAlign: TextAlign.center,
                      textDirection:
                          rtl ? TextDirection.rtl : null,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (entry.isParagraph) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _surface(
                  modern: modern,
                  dark: dark,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      content,
                      textDirection:
                          rtl ? TextDirection.rtl : null,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _surface(
                modern: modern,
                dark: dark,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.number != null) ...[
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 38,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.number}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: SelectableText(
                          content,
                          textDirection:
                              rtl ? TextDirection.rtl : null,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _surface({
    required bool modern,
    required bool dark,
    required Widget child,
  }) {
    if (modern) {
      return ModernGlassPanel(
        color: dark
            ? const Color(0x0AFFFFFF)
            : AppColorModern.glassFill,
        child: child,
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
