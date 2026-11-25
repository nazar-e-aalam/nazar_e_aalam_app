// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nazar_e_alam/controller/nearby_mosque_controller.dart';
import 'package:nazar_e_alam/data/model/response/nearby_mosque_model.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';

class NearbyMosque extends StatefulWidget {
  final bool appBackButton;

  const NearbyMosque({super.key, required this.appBackButton});

  @override
  State<NearbyMosque> createState() => _NearbyMosqueState();
}

class _NearbyMosqueState extends State<NearbyMosque> {
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
    if (_ownsController && Get.isRegistered<NearbyMosqueController>()) {
      Get.delete<NearbyMosqueController>();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'nearby_mosque'.tr,
        isBackButtonExist: widget.appBackButton,
      ),
      body: Obx(() {
        if (controller.isLocationLoading.value) {
          return const NearbyMosqueShimmerScreen();
        }

        if (controller.isLocationServiceDisabled.value) {
          return _buildStatus(
            icon: Icons.location_off_outlined,
            title: 'Location service disabled',
            description: 'Please enable your device location service.',
            onSettings: controller.openLocationSettings,
            onRetry: controller.refreshLocation,
          );
        }

        if (controller.isLocationDenied.value) {
          return _buildStatus(
            icon: Icons.location_disabled_outlined,
            title: 'Location permission required',
            description:
                'location_service_permission_denied_for_getting_this_service_please_enable_location'
                    .tr,
            onSettings: controller.openPermissionSettings,
            onRetry: controller.refreshLocation,
          );
        }

        if (controller.locationError.value.isNotEmpty) {
          return _buildStatus(
            icon: Icons.location_searching,
            title: 'Location unavailable',
            description: controller.locationError.value,
            onRetry: controller.refreshLocation,
          );
        }

        return Column(
          children: [
            _buildSearchHeader(),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const NearbyMosqueShimmerScreen();
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildStatus(
                    icon: Icons.cloud_off_outlined,
                    title: 'Unable to load mosques',
                    description: controller.errorMessage.value,
                    onRetry: controller.refreshMosques,
                  );
                }

                if (controller.places.isEmpty) {
                  return _buildStatus(
                    icon: Icons.mosque_outlined,
                    title: 'No mosques found',
                    description: 'Try increasing the search radius.',
                    onRetry: controller.refreshMosques,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshMosques,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_SMALL,
                      vertical: Dimensions.PADDING_SIZE_SMALL,
                    ),
                    itemCount: controller.places.length,
                    itemBuilder: (context, index) {
                      return _buildMosqueCard(controller.places[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  // ==================== SEARCH HEADER ====================

  Widget _buildSearchHeader() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'if_you_cant_find_the_mosque_according_to_the_predefined_area_then_search_for_the_mosque_by_selecting_area_by_kilometers_from_below'
                .tr,
            textAlign: TextAlign.justify,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.FONT_SIZE_DEFAULT,
              color: theme.primaryColor,
            ),
          ),

          const SizedBox(height: 14),

          // Radius dropdown remains visible during loading.
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
              ),
              child: DropdownButton<int>(
                value: controller.radiusKm.value,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: NearbyMosqueController.availableRadii
                    .map(
                      (radius) => DropdownMenuItem<int>(
                        value: radius,
                        child: Text(translateText('$radius  KM')),
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

          const SizedBox(height: 12),

          Obx(
            () => Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: theme.primaryColor,
                  size: 18,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    controller.isLoading.value
                        ? 'Searching nearby mosques...'
                        : '${controller.places.length} mosques found',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_SMALL,
                      color: theme.hintColor,
                    ),
                  ),
                ),

                IconButton(
                  tooltip: 'Refresh location',
                  onPressed: controller.refreshLocation,
                  icon: Icon(
                    Icons.my_location_rounded,
                    color: theme.primaryColor,
                    size: 21,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MOSQUE CARD ====================

  Widget _buildMosqueCard(MosqueModel mosque) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _openMosqueInMaps(mosque),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.mosque_outlined,
                  color: theme.primaryColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.name,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                      ),
                    ),

                    if (mosque.address?.isNotEmpty == true) ...[
                      const SizedBox(height: 5),

                      Text(
                        mosque.address!,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                          color: theme.hintColor,
                        ),
                      ),
                    ],

                    if (mosque.distanceKm != null) ...[
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            color: theme.primaryColor,
                            size: 14,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            _formatDistance(mosque.distanceKm!),
                            style: robotoMedium.copyWith(
                              color: theme.primaryColor,
                              fontSize: Dimensions.FONT_SIZE_SMALL,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              SvgPicture.asset(
                Images.Icon_Right_Arrow,
                colorFilter: ColorFilter.mode(
                  theme.primaryColor,
                  BlendMode.srcIn,
                ),
                height: 24,
              ),
            ],
          ),
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
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.08),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 36),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                color: theme.hintColor,
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
              ),
            ),

            const SizedBox(height: 20),

            if (onSettings != null)
              FilledButton(
                onPressed: () async {
                  await onSettings();
                },
                child: const Text('Open settings'),
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

  // ==================== DISTANCE ====================

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }

    return '${distanceKm.toStringAsFixed(2)} km';
  }

  // ==================== GOOGLE MAPS ====================

  Future<void> _openMosqueInMaps(MosqueModel mosque) async {
    try {
      Uri? uri;

      if (mosque.googleMapsUrl?.isNotEmpty == true) {
        final candidate = Uri.tryParse(mosque.googleMapsUrl!);

        if (candidate != null &&
            candidate.scheme == 'https' &&
            candidate.host == 'www.google.com' &&
            candidate.path.startsWith('/maps/')) {
          uri = candidate;
        }
      }

      if (uri == null && mosque.hasValidCoordinates) {
        uri = Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': '${mosque.lat},${mosque.lon}',
        });
      }

      if (uri == null) {
        throw Exception('Invalid mosque location');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Unable to launch Google Maps');
      }
    } catch (e) {
      debugPrint('Google Maps Launch Error: $e');

      if (mounted) {
        showCustomSnackBar('please_try_again'.tr, isError: true);
      }
    }
  }
}
