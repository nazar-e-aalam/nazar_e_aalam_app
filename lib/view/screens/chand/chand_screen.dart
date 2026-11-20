// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/chand_controller.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

/// Classic Chand (Islamic Calendar) screen.
class ChandScreen extends StatelessWidget {
  final bool appBackButton;

  const ChandScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChandController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'chand'.tr, isBackButtonExist: appBackButton),
      body: Obx(() {
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

        // final gregorianDate = _displayValue(data.gregorianDate);
        // final city = _formatCity(data.city);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Islamic calendar icon.
              const Text(
                '🌒',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 100, height: 1.0),
              ),

              const SizedBox(height: 24),

              // Hijri date.
              Text(
                hijriDate,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              _buildUpdatedAt(context),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
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

  // Widget _buildInfoCard(
  //   BuildContext context, {
  //   required IconData icon,
  //   required String label,
  //   required String value,
  // }) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 48,
  //           height: 48,
  //           decoration: BoxDecoration(
  //             color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
  //         ),
  //         const SizedBox(width: 16),
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
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 value,
  //                 style: robotoMedium.copyWith(
  //                   fontSize: Dimensions.FONT_SIZE_DEFAULT,
  //                   fontWeight: FontWeight.w600,
  //                   color: Theme.of(context).textTheme.bodyLarge?.color,
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
    // final now = DateFormat('hh:mm a').format(DateTime.now());
    final now = '07:00 PM';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
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

  // String _formatCity(String? city) {
  //   if (city == null || city.trim().isEmpty) {
  //     return '--';
  //   }

  //   return city
  //       .trim()
  //       .replaceAll('_', ' ')
  //       .split(RegExp(r'\s+'))
  //       .map(
  //         (word) => word.isEmpty
  //             ? word
  //             : '${word[0].toUpperCase()}${word.substring(1)}',
  //       )
  //       .join(' ');
  // }
}
