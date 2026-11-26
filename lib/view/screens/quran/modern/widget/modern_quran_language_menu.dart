// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';

class ModernQuranLanguageMenu extends StatelessWidget {
  final Color? iconColor;

  const ModernQuranLanguageMenu({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LocalizationController>();
    final settings = Get.find<SettingsController>();
    final quran = Get.find<QuranController>();
    final theme = Theme.of(context);

    return Obx(() {
      final selected = settings.quranLanguage.value;
      final loading = quran.isLanguageChanging.value;
      final realLang = lang.locale;
      return PopupMenuButton<String>(
        enabled: !loading,

        tooltip: 'quran_language'.tr,

        position: PopupMenuPosition.under,

        offset: const Offset(0, 12),

        elevation: 8,

        color: theme.cardColor,

        surfaceTintColor: Colors.transparent,

        constraints: const BoxConstraints(minWidth: 245, maxWidth: 290),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.12)),
        ),

        popUpAnimationStyle: const AnimationStyle(
          duration: Duration(milliseconds: 220),
          reverseDuration: Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),

        icon: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            : Icon(Icons.translate_rounded, size: 25, color: iconColor),

        onSelected: (language) async {
          try {
            debugPrint('[QuranLanguage] Selected: $language');

            await quran.changeQuranLanguage(language);

            debugPrint('[QuranLanguage] Active: ${quran.currentLanguage}');
          } catch (e, stackTrace) {
            debugPrint('[QuranLanguage] ERROR: $e');
            debugPrintStack(stackTrace: stackTrace);

            showCustomSnackBar('please_try_again'.tr, isError: true);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            enabled: false,

            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,

                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Icon(
                        Icons.translate_rounded,
                        color: theme.primaryColor,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'quran_language'.tr,

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  'select_quran_language'.tr,

                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
              ],
            ),
          ),

          const PopupMenuDivider(height: 8),

          ...settings.availableQuranLanguages.map((language) {
            final code = language['code']!;
            final isSelected = selected == code;

            return PopupMenuItem<String>(
              value: code,

              height: 65,

              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor.withValues(alpha: 0.09)
                      : Colors.transparent,

                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor.withValues(alpha: 0.25)
                        : Colors.transparent,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,

                      alignment: Alignment.center,

                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.08),

                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: code == 'system'
                          ? Icon(
                              Icons.language_rounded,
                              size: 19,
                              color: theme.primaryColor,
                            )
                          : Text(
                              code.toUpperCase(),

                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor,
                              ),
                            ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Text(
                            code == 'system'
                                ? 'same_as_app_language'.tr
                                : language['native']!,

                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            code == 'system'
                                ? realLang.toString().toUpperCase()
                                : language['name']!,

                            style: TextStyle(
                              fontSize: 11,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,

                      size: 20,

                      color: isSelected
                          ? theme.primaryColor
                          : theme.hintColor.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}
