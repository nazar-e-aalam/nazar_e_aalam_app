import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

class QuranLanguageMenu extends StatelessWidget {
  final Color? iconColor;

  const QuranLanguageMenu({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final quran = Get.find<QuranController>();
    final theme = Theme.of(context);

    return Obx(() {
      final selected = settings.quranLanguage.value;
      final loading = quran.isLanguageChanging.value;

      return PopupMenuButton<String>(
        enabled: !loading,

        tooltip: 'quran_language'.tr,

        initialValue: selected,

        position: PopupMenuPosition.under,

        icon: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            : Icon(Icons.translate_rounded, color: iconColor, size: 25),

        onSelected: (language) async {
          try {
            await quran.changeQuranLanguage(language);
          } catch (_) {
            showCustomSnackBar('please_try_again'.tr, isError: true);
          }
        },

        itemBuilder: (context) {
          return settings.availableQuranLanguages.map((language) {
            final code = language['code']!;
            final isSelected = selected == code;

            return PopupMenuItem<String>(
              value: code,

              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,

                    size: 20,

                    color: isSelected ? theme.primaryColor : theme.hintColor,
                  ),

                  const SizedBox(width: 12),

                  Text(
                    code == 'system'
                        ? 'same_as_app_language'.tr
                        : language['native']!,
                  ),
                ],
              ),
            );
          }).toList();
        },
      );
    });
  }
}
