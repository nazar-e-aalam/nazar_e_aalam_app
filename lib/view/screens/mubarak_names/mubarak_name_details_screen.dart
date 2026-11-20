// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/data/model/mubarak_name_model.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';

class MubarakNameDetailsScreen extends StatelessWidget {
  final MubarakName name;

  const MubarakNameDetailsScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localization) {
        final language = Get.find<LocalizationController>().locale.languageCode;
        final settings = Get.find<SettingsController>();

        return Scaffold(
          appBar: CustomAppBar(
            title: name.name(language),
            isBackButtonExist: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: SvgPicture.asset(
                    Images.Bismillah,
                    height: 50,
                    fit: BoxFit.fitHeight,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                Center(
                  child: Text(
                    name.name('en'),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    name.arabicName,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: settings.selectedArabicFont.copyWith(
                      fontSize: settings.arabicFontSize.value + 10,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                Center(
                  child: Text(
                    name.name(language),
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 18),
                Text(
                  'meaning'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name.meaning(language),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                    height: 1.7,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                Text(
                  'benefits'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  name.nameBenefits(language),
                  textAlign: TextAlign.start,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                    height: 1.7,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (name.honorific?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  Center(
                    child: Text(
                      name.honorific!,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: settings.selectedArabicFont.copyWith(
                        fontSize: settings.arabicFontSize.value,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
