// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/data/model/mubarak_category_model.dart';
import 'package:nazar_e_alam/data/repository/mubarak_categories_repository.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'mubarak_category_details_wrapper.dart';

/// Appends the 12 XML-derived categories after the three existing name collections.
/// The repository caches the parsed JSON across Classic/Modern switches.
class MubarakExtraCategories extends StatefulWidget {
  final bool modern;
  const MubarakExtraCategories({super.key, required this.modern});

  @override
  State<MubarakExtraCategories> createState() => _MubarakExtraCategoriesState();
}

class _MubarakExtraCategoriesState extends State<MubarakExtraCategories> {
  late Future<List<MubarakCategory>> _future;

  @override
  void initState() {
    super.initState();
    _future = MubarakCategoriesRepository().load();
  }

  void _retry() {
    MubarakCategoriesRepository.clearCache();

    final nextFuture = MubarakCategoriesRepository().load();

    setState(() {
      _future = nextFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final language = Get.locale?.languageCode ?? 'gu';
    return FutureBuilder<List<MubarakCategory>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  'Unable to load Mubarak Naam categories: ${snapshot.error}',
                ),
                TextButton(onPressed: _retry, child: const Text('Retry')),
              ],
            ),
          );
        }
        final categories = snapshot.data!;
        return Column(
          children: [
            for (var i = 0; i < categories.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: widget.modern ? 14 : 8),
                child: _categoryTile(
                  category: categories[i],
                  index: i,
                  language: language,
                  theme: theme,
                  dark: dark,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _categoryTile({
    required MubarakCategory category,
    required int index,
    required String language,
    required ThemeData theme,
    required bool dark,
  }) {
    final title = category.localizedTitle(language);
    final heading = category.localizedHeading(language);
    if (!widget.modern) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(child: Text('${index + 4}')),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: heading == title
              ? null
              : Text(heading, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () =>
              Get.to(() => MubarakCategoryDetailsWrapper(category: category)),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () =>
            Get.to(() => MubarakCategoryDetailsWrapper(category: category)),
        child: ModernGlassPanel(
          color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                ModernTitleBadge(
                  number: index + 4,
                  size: 44,
                  startColor: dark
                      ? const Color(0xFF2B1D13)
                      : Theme.of(context).primaryColor,
                  endColor: dark
                      ? const Color(0xFF3A2E24).withValues(alpha: 0.5)
                      : AppColorModern.primaryColorDark.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (heading != title) ...[
                        const SizedBox(height: 5),
                        Text(
                          heading,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
