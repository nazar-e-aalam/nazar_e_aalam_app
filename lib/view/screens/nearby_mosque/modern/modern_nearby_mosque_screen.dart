// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/nearby_mosque_controller.dart';
import 'package:nazar_e_alam/data/model/response/nearby_mosque_model.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';
import 'package:nazar_e_alam/view/base/location_error_widget.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'package:url_launcher/url_launcher.dart';

class ModernNearbyMosqueScreen extends StatefulWidget {
  final bool appBackButton;

  const ModernNearbyMosqueScreen({super.key, required this.appBackButton});

  @override
  State<ModernNearbyMosqueScreen> createState() =>
      _ModernNearbyMosqueScreenState();
}

class _ModernNearbyMosqueScreenState extends State<ModernNearbyMosqueScreen> {
  late final NearbyMosqueController controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();

    _ownsController = !Get.isRegistered<NearbyMosqueController>();

    controller = _ownsController
        ? Get.put(NearbyMosqueController(apiClient: Get.find()))
        : Get.find<NearbyMosqueController>();
  }

  @override
  void dispose() {
    if (_ownsController &&
        Get.isRegistered<NearbyMosqueController>() &&
        identical(Get.find<NearbyMosqueController>(), controller)) {
      Get.delete<NearbyMosqueController>();
    }

    super.dispose();
  }

  // ==================== MAIN SCREEN ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      extendBody: true,
      backgroundColor: dark
          ? theme.scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'nearby_mosque'.tr,
        isBackButtonExist: widget.appBackButton,
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          // Initial GPS location loading.
          if (controller.isLocationLoading.value) {
            return const NearbyMosqueShimmerScreen();
          }

          // Location permission denied.
          if (controller.isLocationDenied.value) {
            return _buildLocationDenied();
          }

          // GPS service disabled.
          if (controller.isLocationServiceDisabled.value) {
            return _buildStatus(
              icon: Icons.location_off_outlined,
              title: 'location_service_disabled'.tr,
              description: 'enable_location_service'.tr,
              onSettings: controller.openLocationSettings,
              onRetry: controller.refreshLocation,
            );
          }

          // Location acquisition error.
          if (controller.locationError.value.isNotEmpty) {
            return _buildStatus(
              icon: Icons.location_searching_rounded,
              title: 'location_unavailable'.tr,
              description: controller.locationError.value,
              onRetry: controller.refreshLocation,
            );
          }

          return ModernGlassPanel(
            color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
            child: Column(
              children: [
                _buildSearchHint(context),

                const SizedBox(height: 10),

                _buildKmDropdown(context),

                const SizedBox(height: 10),

                _buildResultsHeader(context),

                const SizedBox(height: 4),

                // Only this section changes when searching.
                Expanded(child: _buildResults(context)),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==================== SEARCH HINT ====================

  Widget _buildSearchHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        0,
      ),
      child: Text(
        'if_you_cant_find_the_mosque_according_to_the_predefined_area_then_search_for_the_mosque_by_selecting_area_by_kilometers_from_below'
            .tr,
        textAlign: TextAlign.justify,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.FONT_SIZE_DEFAULT,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ==================== RADIUS DROPDOWN ====================

  Widget _buildKmDropdown(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_SMALL,
          vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
          color: theme.cardColor,
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Obx(
          () => DropdownButton<int>(
            menuMaxHeight: 500,
            value: controller.radiusKm.value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.primaryColor,
            ),
            items: NearbyMosqueController.availableRadii
                .map(
                  (radius) => DropdownMenuItem<int>(
                    value: radius,
                    child: Text(
                      translateText('$radius  KM'),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.changeRadius(value);
              }
            },
          ),
        ),
      ),
    );
  }

  // ==================== RESULTS HEADER ====================

  Widget _buildResultsHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
      ),
      child: Obx(() {
        final loading = controller.isLoading.value;
        final count = controller.places.length;
        final hasError = controller.errorMessage.value.isNotEmpty;

        return Row(
          children: [
            Icon(Icons.mosque_outlined, color: theme.primaryColor, size: 18),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                loading
                    ? 'searching_nearby_mosques'.tr
                    : hasError
                    ? 'unable_to_load_mosques'.tr
                    : '${translateText('$count')} '
                          '${'mosques_found'.tr}',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_SMALL,
                  color: theme.hintColor,
                ),
              ),
            ),

            IconButton(
              tooltip: 'refresh_location'.tr,
              visualDensity: VisualDensity.compact,
              onPressed: controller.refreshLocation,
              icon: Icon(
                Icons.my_location_rounded,
                size: 20,
                color: theme.primaryColor,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ==================== RESULTS STATE ====================

  Widget _buildResults(BuildContext context) {
    return Obx(() {
      // Radius change: only results show shimmer.
      if (controller.isLoading.value) {
        return const NearbyMosqueShimmerScreen();
      }

      // API or network error.
      if (controller.errorMessage.value.isNotEmpty) {
        return _buildStatus(
          icon: Icons.cloud_off_outlined,
          title: 'unable_to_load_mosques'.tr,
          description: controller.errorMessage.value,
          onRetry: controller.refreshMosques,
        );
      }

      // No results.
      if (controller.places.isEmpty) {
        return _buildStatus(
          icon: Icons.mosque_outlined,
          title: 'no_mosques_found'.tr,
          description: 'try_increasing_search_radius'.tr,
          onRetry: controller.refreshMosques,
        );
      }

      // Mosque list.
      return _buildMosqueList(context);
    });
  }

  // ==================== MOSQUE LIST ====================

  Widget _buildMosqueList(BuildContext context) {
    // Take a snapshot to avoid indexing a changing RxList.
    final places = controller.places.toList(growable: false);
    final mosqueCount = places.length;

    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: controller.refreshMosques,
      child: ListView.builder(
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: mosqueCount + 1,
        padding: const EdgeInsets.fromLTRB(
          Dimensions.PADDING_SIZE_DEFAULT,
          8,
          Dimensions.PADDING_SIZE_DEFAULT,
          Dimensions.PADDING_SIZE_EXTRA_LARGE,
        ),
        itemBuilder: (context, index) {
          // Preserve spacing for bottom navigation.
          if (index == mosqueCount) {
            return const SizedBox(height: 90);
          }

          final mosque = places[index];

          return ModernListItem(
            key: ValueKey(
              'mosque_${mosque.name}_${mosque.lat}_${mosque.lon}_$index',
            ),
            index: index + 1,
            title: mosque.name,
            subtitle: mosque.address?.isNotEmpty == true
                ? mosque.address!
                : '--',
            trailing: mosque.distanceKm != null
                ? _formatDistance(mosque.distanceKm!)
                : null,
            accentColor: Theme.of(context).primaryColor,
            isFirst: index == 0,
            isLast: index == mosqueCount - 1,
            onTap: () => _openMosqueInMaps(mosque),
          );
        },
      ),
    );
  }

  // ==================== LOCATION DENIED ====================

  Widget _buildLocationDenied() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocationErrorWidget(
              error:
                  'location_service_permission_denied_for_getting_this_service_please_enable_location'
                      .tr,
            ),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: controller.openPermissionSettings,
              child: Text('open_settings'.tr),
            ),

            TextButton.icon(
              onPressed: controller.refreshLocation,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('please_try_again'.tr),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ERROR / EMPTY STATE ====================

  Widget _buildStatus({
    required IconData icon,
    required String title,
    required String description,
    Future<void> Function()? onRetry,
    Future<void> Function()? onSettings,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(alpha: 0.08),
              ),
              child: Icon(icon, size: 34, color: theme.primaryColor),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                color: theme.hintColor,
              ),
            ),

            const SizedBox(height: 16),

            if (onSettings != null)
              FilledButton(
                onPressed: () async {
                  await onSettings();
                },
                child: Text('open_settings'.tr),
              ),

            if (onRetry != null)
              TextButton.icon(
                onPressed: () async {
                  await onRetry();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text('please_try_again'.tr),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== DISTANCE FORMAT ====================

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return translateText('${(distanceKm * 1000).round()} m');
    }

    return translateText('${distanceKm.toStringAsFixed(2)} km');
  }

  // ==================== GOOGLE MAPS ====================

  Future<void> _openMosqueInMaps(MosqueModel mosque) async {
    try {
      Uri? destination;

      final mapsUrl = mosque.googleMapsUrl;

      if (mapsUrl != null && mapsUrl.isNotEmpty) {
        final candidate = Uri.tryParse(mapsUrl);

        if (candidate != null &&
            candidate.scheme == 'https' &&
            candidate.host == 'www.google.com' &&
            candidate.path.startsWith('/maps/')) {
          destination = candidate;
        }
      }

      // Fallback to coordinates.
      if (destination == null && mosque.hasValidCoordinates) {
        destination = Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': '${mosque.lat},${mosque.lon}',
        });
      }

      if (destination == null) {
        throw const FormatException('Invalid mosque destination');
      }

      final launched = await launchUrl(
        destination,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Unable to launch Google Maps');
      }
    } catch (e) {
      debugPrint('Google Maps launch error: $e');

      if (mounted) {
        showCustomSnackBar('please_try_again'.tr, isError: true);
      }
    }
  }
}
