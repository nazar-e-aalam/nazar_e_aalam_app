// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/util/styles.dart';

class ModernQuranListItem extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final String arabicName;
  final VoidCallback onTap;

  const ModernQuranListItem({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.arabicName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final settings = Get.find<SettingsController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    number,
                    style: robotoBold.copyWith(color: primary, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  flex: 3,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: robotoMedium.copyWith(
                            fontSize: settings.translateFontSize.value,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: robotoRegular.copyWith(
                            fontSize: (settings.translateFontSize.value - 3)
                                .clamp(10.0, 100.0)
                                .toDouble(),
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  flex: 2,
                  child: Obx(
                    () => Text(
                      arabicName,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.end,
                      style: settings.selectedArabicFont.copyWith(
                        fontSize: settings.arabicFontSize.value,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                Icon(Icons.chevron_right_rounded, color: primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
