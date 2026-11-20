// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';

class NearbyMosqueController extends GetxController {
  GlobalKey<FormState> nearbyMosqueFormKey = GlobalKey<FormState>();
  final ApiClient apiClient;
  NearbyMosqueController({required this.apiClient});

  // Location
  var location = '';
  double? latitude;
  double? longitude;

  RxString currentAddress = '--'.obs;
  StreamSubscription<Position>? streamSubscription;
  late LocationSettings locationSettings;

  RxBool isLocationDenied = false.obs;

  // Existing UI state
  var userLocation = ''.obs;
  var places = <dynamic>[].obs;
  RxBool isLoading = false.obs;

  List<String> splitKm = [];
  int kmToRadious = 2;
  var km = '2  KM'.obs;

  // bool _requestInProgress = false;

  @override
  void onInit() {
    super.onInit();
    loadKmDropdownValue(km.value);
  }

  @override
  void onClose() {
    streamSubscription?.cancel();
    super.onClose();
  }

  Future<void> getLocation() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        isLocationDenied.value = true;
        await prefs.setBool('isLocationDenied', true);

        showCustomSnackBar(
          'for_getting_Automatic_Prayer_Time_Nearby_Mosque_Qibla_Compass_need_to_enable_location_permission'
              .tr,
          isError: true,
          onTap: () => openAppSettings(),
        );
        return;
      }

      isLocationDenied.value = false;
      await prefs.setBool('isLocationDenied', false);

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      latitude = position.latitude;
      longitude = position.longitude;

      userLocation.value = '$latitude,$longitude';

      await searchNearbyPlaces();
      update();
    } catch (e) {
      debugPrint('Nearby Mosque Location Error: $e');

      showCustomSnackBar(
        'Unable to get your location. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> searchNearbyPlaces() async {
    if (isLoading.value) return;

    final userLat = latitude;
    final userLon = longitude;
    final radiusKm = kmToRadious;

    if (userLat == null || userLon == null) {
      debugPrint('Nearby Mosque: Location unavailable');
      return;
    }

    isLoading.value = true;
    update();

    try {
      final radiusMeters = radiusKm * 1000;

      final response = await apiClient.getData(
        Endpoints.NEARBY_MOSQUE_URL,
        query: {
          'lat': userLat.toString(),
          'lon': userLon.toString(),
          'radius_m': radiusMeters.toString(),
        },
      );

      if (response.statusCode != 200) {
        debugPrint('Nearby Mosque API Error: ${response.statusCode}');
        return;
      }

      final body = response.body;

      List<dynamic> results;

      if (body is List) {
        results = body;
      } else if (body is Map) {
        final mosques = body['mosques'] ?? body['results'] ?? body['data'];

        if (mosques is! List) {
          throw const FormatException(
            'Invalid nearby mosque response structure',
          );
        }

        results = mosques;
      } else {
        throw const FormatException('Invalid nearby mosque API response');
      }

      final List<Map<String, dynamic>> processedMosques = [];

      for (final item in results) {
        if (item is! Map) continue;

        final mosque = Map<String, dynamic>.from(item);

        final mosqueLat = mosque['lat'];
        final mosqueLon = mosque['lon'];

        if (mosqueLat is! num || mosqueLon is! num) {
          continue;
        }

        final lat = mosqueLat.toDouble();
        final lon = mosqueLon.toDouble();

        if (!lat.isFinite ||
            !lon.isFinite ||
            lat < -90 ||
            lat > 90 ||
            lon < -180 ||
            lon > 180) {
          continue;
        }

        // Calculate straight-line distance in kilometers.
        final distanceKm =
            Geolocator.distanceBetween(userLat, userLon, lat, lon) / 1000.0;

        // Ensure results are within the selected radius.
        if (distanceKm > radiusKm) {
          continue;
        }

        // Preserve original backend fields.
        mosque['distance_km'] = distanceKm;

        // Compatibility with existing Google Places UI.
        mosque['vicinity'] = mosque['address'] ?? '';

        mosque['geometry'] = {
          'location': {'lat': lat, 'lng': lon},
        };

        processedMosques.add(mosque);
      }

      // Sort nearest first.
      processedMosques.sort((a, b) {
        final distanceA = (a['distance_km'] as num).toDouble();

        final distanceB = (b['distance_km'] as num).toDouble();

        return distanceA.compareTo(distanceB);
      });

      // Prevent an older request from replacing results
      // after the user has selected another radius.
      if (radiusKm != kmToRadious ||
          userLat != latitude ||
          userLon != longitude) {
        debugPrint(
          'Nearby Mosque: Search parameters changed, '
          'discarding outdated results',
        );
        return;
      }

      places.assignAll(processedMosques);

      debugPrint(
        'Nearby Mosque: '
        '${results.length} received, '
        '${processedMosques.length} within '
        '$radiusKm KM',
      );
    } catch (e) {
      debugPrint('Nearby Mosque Error: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void loadKmDropdownValue(String newValue) {
    km.value = newValue;

    splitKm = newValue.trim().split(RegExp(r'\s+'));

    final parsedKm = int.tryParse(splitKm.first);

    if (parsedKm != null && parsedKm > 0) {
      kmToRadious = parsedKm;
    }

    update();

    // Refresh only if location is already available.
    if (latitude != null && longitude != null) {
      searchNearbyPlaces();
    }
  }
}
