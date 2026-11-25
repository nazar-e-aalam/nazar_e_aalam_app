// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/chand_controller.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

/// Modern Chand (Islamic Calendar) screen.
class ModernChandScreen extends StatelessWidget {
  final bool appBackButton;

  const ModernChandScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChandController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(title: 'chand'.tr, isBackButtonExist: appBackButton),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ChandShimmer();
          }

          final data = controller.chandData.value;

          if (data == null) {
            return _buildEmptyState(context, controller);
          }

          final hijriDate = _hijriDate(
            day: data.hijriDay,
            month: data.hijriMonthName,
            year: data.hijriYear,
          );

          final gregorianDate = _displayValue(data.gregorianDate);
          final city = _formatCity(data.city);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Modern Islamic calendar header.
                ModernGlassPanel(
                  color: dark
                      ? const Color(0x0AFFFFFF)
                      : AppColorModern.glassFill,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: dark
                            ? const [Color(0xFF1A1A1A), Color(0xFF2A1A12)]
                            : [
                                Theme.of(context).primaryColor,
                                AppColorModern.primaryColorDark,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        // Container(
                        //   width: 100,
                        //   height: 100,
                        //   // decoration: BoxDecoration(
                        //   //   color: Colors.white.withValues(alpha: 0.12),
                        //   //   shape: BoxShape.circle,
                        //   //   border: Border.all(
                        //   //     color: Colors.white.withValues(alpha: 0.25),
                        //   //     width: 1.5,
                        //   //   ),
                        //   // ),
                        const Text(
                          '🌒',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 85, height: 0),
                        ),
                        // ),
                        const SizedBox(height: 22),
                        Text(
                          hijriDate,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gregorianDate,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          city,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_SMALL,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // const SizedBox(height: 24),

                // _buildModernInfoCard(
                //   context,
                //   icon: Icons.calendar_today_rounded,
                //   label: 'hijri_date'.tr,
                //   value: hijriDate,
                //   accentColor: AppColorModern.primaryColor,
                // ),

                // const SizedBox(height: 16),

                // _buildModernInfoCard(
                //   context,
                //   icon: Icons.event_rounded,
                //   label: 'Gregorian Date',
                //   value: gregorianDate,
                //   accentColor: AppColorModern.primaryColor,
                // ),

                // const SizedBox(height: 16),

                // _buildModernInfoCard(
                //   context,
                //   icon: Icons.location_city_rounded,
                //   label: 'City',
                //   value: city,
                //   accentColor: AppColorModern.primaryColor,
                // ),
                const SizedBox(height: 30),

                _buildUpdatedAt(context),

                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ChandController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'chand_no_data'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load the Islamic calendar. Please try again.',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.FONT_SIZE_SMALL,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.fetchChandData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildModernInfoCard(
  //   BuildContext context, {
  //   required IconData icon,
  //   required String label,
  //   required String value,
  //   required Color accentColor,
  // }) {
  //   final dark = Theme.of(context).brightness == Brightness.dark;

  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor.withValues(alpha: 0.6),
  //       borderRadius: BorderRadius.circular(18),
  //       border: Border.all(color: accentColor.withValues(alpha: 0.2)),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 44,
  //           height: 44,
  //           decoration: BoxDecoration(
  //             color: accentColor.withValues(alpha: 0.10),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Icon(icon, color: accentColor, size: 22),
  //         ),
  //         const SizedBox(width: 14),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 label,
  //                 style: robotoMedium.copyWith(
  //                   fontSize: Dimensions.FONT_SIZE_SMALL,
  //                   color: Theme.of(
  //                     context,
  //                   ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 value,
  //                 style: robotoMedium.copyWith(
  //                   fontSize: Dimensions.FONT_SIZE_DEFAULT,
  //                   fontWeight: FontWeight.w600,
  //                   color: dark ? Colors.white : AppColorModern.textPrimary,
  //                 ),
  //                 maxLines: 2,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildUpdatedAt(BuildContext context) {
    final now = DateFormat('hh:mm a').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            '${'updated_at'.tr} $now',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.FONT_SIZE_SMALL,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _hijriDate({
    required int? day,
    required String? month,
    required int? year,
  }) {
    final dayText = day?.toString() ?? '--';
    final monthText = _displayValue(month);
    final yearText = year?.toString() ?? '--';

    return '$dayText $monthText $yearText';
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '--';
    }

    return value.trim();
  }

  String _formatCity(String? city) {
    if (city == null || city.trim().isEmpty) {
      return '--';
    }

    return city
        .trim()
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
