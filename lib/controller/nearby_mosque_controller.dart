// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/data/model/response/nearby_mosque_model.dart';

class NearbyMosqueController extends GetxController {
  final ApiClient apiClient;

  NearbyMosqueController({required this.apiClient});

  // ==================== LOCATION ====================

  double? latitude;
  double? longitude;

  final RxString userLocation = ''.obs;

  final RxBool isLocationLoading = true.obs;
  final RxBool isLocationDenied = false.obs;
  final RxBool isLocationServiceDisabled = false.obs;

  final RxString locationError = ''.obs;

  // ==================== MOSQUES ====================

  final RxList<MosqueModel> places = <MosqueModel>[].obs;

  final Rxn<NearbyMosqueModel> nearbyMosqueModel = Rxn<NearbyMosqueModel>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ==================== RADIUS ====================

  final RxInt radiusKm = 2.obs;

  static const List<int> availableRadii = [1, 2, 3, 4, 5];

  // Prevent outdated responses from updating the UI.
  int _requestId = 0;

  bool get hasLocation => latitude != null && longitude != null;

  @override
  void onInit() {
    super.onInit();
    getLocation();
  }

  @override
  void onClose() {
    _requestId++;
    super.onClose();
  }

  // ==================== GET LOCATION ====================

  Future<void> getLocation({bool forceRefresh = false}) async {
    if (isClosed) return;

    // Invalidate any previous mosque request.
    _requestId++;

    isLocationLoading.value = true;
    isLoading.value = false;

    isLocationDenied.value = false;
    isLocationServiceDisabled.value = false;

    locationError.value = '';
    errorMessage.value = '';

    latitude = null;
    longitude = null;
    userLocation.value = '';

    places.clear();
    nearbyMosqueModel.value = null;

    try {
      final prefs = await SharedPreferences.getInstance();

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (isClosed) return;

      if (!serviceEnabled) {
        isLocationServiceDisabled.value = true;
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (isClosed) return;

      final denied =
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever;

      isLocationDenied.value = denied;

      await prefs.setBool('isLocationDenied', denied);

      if (isClosed || denied) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (isClosed) return;

      latitude = position.latitude;
      longitude = position.longitude;

      userLocation.value = '$latitude,$longitude';

      await searchNearbyPlaces(forceRefresh: forceRefresh);
    } catch (e) {
      debugPrint('Nearby Mosque Location Error: $e');

      if (!isClosed) {
        locationError.value = 'Unable to get your location. Please try again.';
      }
    } finally {
      if (!isClosed) {
        isLocationLoading.value = false;
      }
    }
  }

  // ==================== SEARCH MOSQUES ====================

  Future<void> searchNearbyPlaces({bool forceRefresh = false}) async {
    if (isClosed) return;

    final userLat = latitude;
    final userLon = longitude;

    if (userLat == null || userLon == null) {
      return;
    }

    final selectedRadius = radiusKm.value;
    final requestId = ++_requestId;

    isLoading.value = true;
    errorMessage.value = '';

    places.clear();
    nearbyMosqueModel.value = null;

    try {
      final response = await apiClient.getData(
        Endpoints.NEARBY_MOSQUE,
        query: {
          'lat': userLat,
          'lon': userLon,
          'radius_m': selectedRadius * 1000,
        },
        cacheDuration: const Duration(minutes: 15),
        forceRefresh: forceRefresh,
        offlineFallback: false,
      );

      // Ignore outdated or disposed requests.
      if (isClosed || requestId != _requestId) {
        return;
      }

      if (response.statusCode != 200) {
        errorMessage.value =
            response.statusText ?? 'Unable to load nearby mosques';

        return;
      }

      final body = response.body;

      if (body is! Map) {
        throw const FormatException('Invalid nearby mosque response');
      }

      final model = NearbyMosqueModel.fromJson(Map<String, dynamic>.from(body));

      final List<MosqueModel> processedMosques = [];

      for (final mosque in model.mosques) {
        if (!mosque.hasValidCoordinates) {
          continue;
        }

        // Straight-line distance in kilometers.
        final distanceKm =
            Geolocator.distanceBetween(
              userLat,
              userLon,
              mosque.lat!,
              mosque.lon!,
            ) /
            1000.0;

        // Enforce the selected radius locally.
        if (distanceKm > selectedRadius) {
          continue;
        }

        processedMosques.add(mosque.copyWith(distanceKm: distanceKm));
      }

      // Nearest mosque first.
      processedMosques.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));

      if (isClosed || requestId != _requestId) {
        return;
      }

      nearbyMosqueModel.value = NearbyMosqueModel(
        source: model.source,
        count: processedMosques.length,
        mosques: processedMosques,
      );

      places.assignAll(processedMosques);

      debugPrint(
        'Nearby Mosque | '
        'Source: ${model.source} | '
        'Received: ${model.count} | '
        'Displayed: ${processedMosques.length} | '
        'Radius: $selectedRadius KM',
      );
    } catch (e) {
      debugPrint('Nearby Mosque API Error: $e');

      if (!isClosed && requestId == _requestId) {
        errorMessage.value = 'Unable to load nearby mosques. Please try again.';
      }
    } finally {
      // An older request must not stop a newer shimmer.
      if (!isClosed && requestId == _requestId) {
        isLoading.value = false;
      }
    }
  }

  // ==================== CHANGE RADIUS ====================

  Future<void> changeRadius(int newRadius) async {
    if (isClosed ||
        !availableRadii.contains(newRadius) ||
        radiusKm.value == newRadius) {
      return;
    }

    radiusKm.value = newRadius;

    if (hasLocation) {
      await searchNearbyPlaces();
    }
  }

  // ==================== REFRESH ====================

  Future<void> refreshMosques() async {
    if (isLocationLoading.value) return;

    if (hasLocation) {
      await searchNearbyPlaces(forceRefresh: true);
    } else {
      await getLocation(forceRefresh: true);
    }
  }

  Future<void> refreshLocation() async {
    if (isLocationLoading.value) return;

    await getLocation(forceRefresh: true);
  }

  // ==================== SETTINGS ====================

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openPermissionSettings() async {
    await Geolocator.openAppSettings();
  }
}
