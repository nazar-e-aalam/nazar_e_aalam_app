// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/nearby_mosque_controller.dart';
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

/// Modern Nearby Mosque screen — glass surface, animated mosque cards.
class ModernNearbyMosqueScreen extends StatelessWidget {
  final bool appBackButton;
  const ModernNearbyMosqueScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    Get.put(NearbyMosqueController(apiClient: Get.find())).getLocation();
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: false,
      extendBody: true,
      // backgroundColor: Colors.transparent,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'nearby_mosque'.tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<NearbyMosqueController>(
          init: NearbyMosqueController(apiClient: Get.find()),
          builder: (nearbyMosqueController) {
            return Obx(
              () =>
                  nearbyMosqueController.isLoading.value ||
                      nearbyMosqueController.userLocation.value == ""
                  ? SizedBox(
                      height: Get.height / 1.2,
                      child: Center(
                        child:
                            nearbyMosqueController.isLocationDenied.value ==
                                true
                            ? LocationErrorWidget(
                                error:
                                    "location_service_permission_denied_for_getting_this_service_please_enable_location"
                                        .tr,
                              )
                            : const NearbyMosqueShimmerScreen(),
                      ),
                    )
                  : ModernGlassPanel(
                      color: dark
                          ? const Color(0x0AFFFFFF)
                          : AppColorModern.glassFill,
                      child: Column(
                        children: [
                          _buildSearchHint(context),
                          const SizedBox(height: 10),
                          _buildKmDropdown(context, nearbyMosqueController),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _buildMosqueList(
                              context,
                              nearbyMosqueController,
                            ),
                          ),
                          // const SizedBox(height: 110),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        0,
      ),
      child: Text(
        "if_you_cant_find_the_mosque_according_to_the_predefined_area_then_search_for_the_mosque_by_selecting_area_by_kilometers_from_below"
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

  Widget _buildKmDropdown(
    BuildContext context,
    NearbyMosqueController nearbyMosqueController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_SMALL,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
          ),
          child: DropdownButton<String>(
            menuMaxHeight: 500,
            value: nearbyMosqueController.km.value,
            items: <String>['1  KM', '2  KM', '3  KM', '4  KM', '5  KM'].map((
              String value,
            ) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  translateText(value),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                nearbyMosqueController.loadKmDropdownValue(newValue);
              }
            },
            isExpanded: true,
            underline: const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildMosqueList(
    BuildContext context,
    NearbyMosqueController nearbyMosqueController,
  ) {
    final places = nearbyMosqueController.places;
    final mosqueCount = places.length;

    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: mosqueCount + 1,
      padding: const EdgeInsets.fromLTRB(
        Dimensions.PADDING_SIZE_DEFAULT,
        8,
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_EXTRA_LARGE,
      ),
      itemBuilder: (BuildContext context, int index) {
        // Extra space after the final mosque for the bottom bar.
        if (index == mosqueCount) {
          return const SizedBox(height: 90);
        }

        final place = places[index];

        final lat = (place['lat'] as num).toDouble();
        final lng = (place['lon'] as num).toDouble();

        return ModernListItem(
          key: ValueKey('mosque_$index'),
          index: index + 1,
          title: place['name'] ?? '--',
          subtitle: place['address'] ?? '--',
          accentColor: Theme.of(context).primaryColor,
          isFirst: index == 0,
          isLast: index == mosqueCount - 1,
          onTap: () async {
            final mapsUrl = place['google_maps_url'];

            final uri = mapsUrl is String && mapsUrl.isNotEmpty
                ? Uri.tryParse(mapsUrl)
                : null;

            final destination =
                uri ??
                Uri.https('www.google.com', '/maps/search/', {
                  'api': '1',
                  'query': '$lat,$lng',
                });

            try {
              final launched = await launchUrl(
                destination,
                mode: LaunchMode.externalApplication,
              );

              if (!launched) {
                showCustomSnackBar('please_try_again'.tr, isError: true);
              }
            } catch (e) {
              debugPrint('Google Maps launch error: $e');

              showCustomSnackBar('please_try_again'.tr, isError: true);
            }
          },
        );
      },
    );
  }
}
