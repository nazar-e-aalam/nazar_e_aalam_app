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
      (
        MubarakNamesCategory.allah,
        '99 Names of Allah ﷻ',
        // 'أَسْمَاءُ اللَّهِ الْحُسْنَى',
        1,
      ),
      (
        MubarakNamesCategory.muhammad,
        '99 Names of Muhammad ﷺ',
        // 'أَسْمَاءُ النَّبِيِّ ﷺ',
        2,
      ),
      (
        MubarakNamesCategory.ghaus,
        '11 Names of Ghaus-e-Azam',
        // 'غوثِ اعظم',
        3,
      ),
    ];
    return Scaffold(
      backgroundColor: dark
          ? theme.scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'Mubarak Names',
        isBackButtonExist: appBackButton,
      ),
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
                    onTap: () => Get.to(
                      () => MubarakNamesListWrapper(category: item.$1),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: dark
                            ? const Color(0x0AFFFFFF)
                            : AppColorModern.glassFill,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.15)
                              : AppColorModern.divider.withValues(alpha: 0.8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: dark ? 0.25 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),

                        child: Row(
                          children: [
                            ModernTitleBadge(
                              number: item.$3,
                              size: 44,
                              startColor: dark
                                  ? const Color(0xFF2B1D13)
                                  : Theme.of(context).primaryColor,
                              endColor: dark
                                  ? const Color(0xFF3A2E24).withValues(alpha: 0.5)
                                  : AppColorModern.primaryColorDark
                                      .withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.$2,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  // const SizedBox(height: 3),
                                  // Text(
                                  //   item.$2,
                                  //   textDirection: TextDirection.rtl,
                                  //   style: theme.textTheme.bodyLarge,
                                  // ),
                                  // const SizedBox(height: 5),
                                  // Text(
                                  //   item.$4,
                                  //   style: theme.textTheme.bodySmall,
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: primary,
                            ),
                          ],
                        ),
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
