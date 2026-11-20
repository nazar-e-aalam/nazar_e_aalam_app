// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/data/repository/mubarak_names_repository.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import '../mubarak_names_list_wrapper.dart';
import '../mubarak_extra_categories.dart';

class ModernMubarakNamesScreen extends StatelessWidget {
  final bool appBackButton;
  const ModernMubarakNamesScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final existing = [
      (MubarakNamesCategory.allah, '99 Names of Allah ﷻ', 'أَسْمَاءُ اللَّهِ الْحُسْنَى', '99 sacred names', Icons.auto_awesome_rounded),
      (MubarakNamesCategory.muhammad, '99 Names of Muhammad ﷺ', 'أَسْمَاءُ النَّبِيِّ ﷺ', '99 blessed names', Icons.menu_book_rounded),
      (MubarakNamesCategory.ghaus, '11 Names of Ghaus-e-Azam', 'غوثِ اعظم', '11 blessed titles', Icons.stars_rounded),
    ];
    return Scaffold(
      backgroundColor: dark ? theme.scaffoldBackgroundColor : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(title: 'Mubarak Names', isBackButtonExist: appBackButton),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            for (final item in existing)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Get.to(() => MubarakNamesListWrapper(category: item.$1)),
                    child: ModernGlassPanel(
                      color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(children: [
                          Container(
                            width: 54, height: 54,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(item.$5, color: primary, size: 27),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item.$2, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 5),
                            Text(item.$3, textDirection: TextDirection.rtl, style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 5),
                            Text(item.$4, style: theme.textTheme.bodySmall),
                          ])),
                          const SizedBox(width: 6),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: primary),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            const MubarakExtraCategories(modern: true),
          ],
        ),
      ),
    );
  }
}
