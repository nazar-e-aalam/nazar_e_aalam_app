// ignore_for_file: deprecated_member_use

import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/data/model/response/hadith_model.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

/// Modern Hadith Details screen — glass surface, gradient info cards.
class ModernHadithDetailsScreen extends StatelessWidget {
  final bool appBackButton;
  ModernHadithDetailsScreen({super.key, required this.appBackButton});

  final Data data = Get.arguments as Data;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: "hadith_details".tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),
      body: SafeArea(
        child: ModernGlassPanel(
          color: dark
              ? const Color(0x0AFFFFFF)
              : AppColorModern.glassFill,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bismillah header
                Center(
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SvgPicture.asset(
                      Images.Bismillah,
                      height: 50,
                      fit: BoxFit.fitHeight,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Arabic section
                _buildSectionHeader(context, "hadith_arabic".tr),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColorModern.divider.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    data.hadithArabic.toString(),
                    textAlign: TextAlign.right,
                    style: Get.find<SettingsController>()
                        .selectedArabicFont
                        .copyWith(
                      fontSize: Get.find<SettingsController>()
                          .arabicFontSize
                          .value,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // English section
                _buildSectionHeader(context, "hadith_english".tr),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColorModern.divider.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    data.hadithEnglish.toString(),
                    textAlign: TextAlign.justify,
                    style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                  ),
                ),
                const SizedBox(height: 24),
                // Info cards
                _buildInfoCard(
                  context,
                  icon: Icons.numbers,
                  label: "hadith_number".tr,
                  value: data.hadithNumber.toString(),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.book,
                  label: "book_name".tr,
                  value: data.book!.bookName!,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.person,
                  label: "writer_name".tr,
                  value: data.book!.writerName!,
                ),
                const SizedBox(height: 12),
                if (data.book!.writerDeath != null &&
                    data.book!.writerDeath!.isNotEmpty)
                  _buildInfoCard(
                    context,
                    icon: Icons.event,
                    label: "writer_death".tr,
                    value: data.book!.writerDeath!,
                  ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.numbers,
                  label: "chapter_number".tr,
                  value: data.chapter!.chapterNumber!.toString(),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.bookmark,
                  label: "chapter_name".tr,
                  value: data.chapter!.chapterEnglish!,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.person,
                  label: "english_narrator".tr,
                  value: data.englishNarrator ?? "",
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: robotoBold.copyWith(
            fontSize: Dimensions.FONT_SIZE_DEFAULT,
            color: dark ? Colors.white : AppColorModern.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorModern.divider.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_SMALL,
                    color: Theme.of(context).textTheme.bodyMedium!.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                    color: darkText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color darkText(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? Colors.white : AppColorModern.textPrimary;
  }
}
