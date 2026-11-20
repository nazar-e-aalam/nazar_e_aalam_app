// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/data/model/mubarak_name_model.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

class ModernMubarakNameDetailsScreen extends StatelessWidget {
  final MubarakName name;

  const ModernMubarakNameDetailsScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final language = Get.locale?.languageCode ?? 'en';
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: dark
          ? theme.scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(title: name.name(language), isBackButtonExist: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModernGlassPanel(
                color: dark
                    ? const Color(0x0AFFFFFF)
                    : AppColorModern.glassFill,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 26,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${name.id}',
                          style: robotoBold.copyWith(color: primary),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SvgPicture.asset(
                        Images.Bismillah,
                        height: 42,
                        colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        name.arabicName,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: settings.selectedArabicFont.copyWith(
                          fontSize: settings.arabicFontSize.value + 12,
                          height: 1.9,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name.name(language),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (name.name(language) != name.name('en')) ...[
                        const SizedBox(height: 8),
                        Text(
                          name.name('en'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (name.honorific?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 16),
                        Text(
                          name.honorific!,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: settings.selectedArabicFont.copyWith(
                            fontSize: settings.arabicFontSize.value,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ModernGlassPanel(
                color: dark
                    ? const Color(0x0AFFFFFF)
                    : AppColorModern.glassFill,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'meaning'.tr,
                            style: robotoBold.copyWith(fontSize: 19),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name.meaning(language),
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              ModernGlassPanel(
                color: dark
                    ? const Color(0x0AFFFFFF)
                    : AppColorModern.glassFill,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'benefits'.tr,
                              style: robotoBold.copyWith(fontSize: 19),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name.nameBenefits(language),
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
