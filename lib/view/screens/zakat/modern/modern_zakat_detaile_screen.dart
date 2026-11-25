// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

/// Modern Zakat Detail screen — glass surface.
class ModernZakatDetaileScreen extends StatelessWidget {
  final bool appBackButton;
  const ModernZakatDetaileScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Get.find<SettingsController>().fetchMosqueSettingsData();
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: "about_zakat".tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),
      body: SafeArea(
        child: ModernGlassPanel(
          color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColorModern.divider.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      // Get.find<SettingsController>()
                      //     .mosqueSettingsApiData!
                      //     .data!
                      //     .zakatDescription
                      //     .toString(),
                      'Hello',
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
