import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import '../data/model/response/chand_model.dart';

class ChandController extends GetxController {
  final ApiClient apiClient;

  ChandController({required this.apiClient});

  final Rx<ChandModel?> chandData = Rx<ChandModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChandData();
  }

  Future<void> fetchChandData() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final prayerTimeController = Get.find<PrayerTimeController>();

      final city = prayerTimeController.currentAddress
          .toString()
          .trim()
          .toLowerCase();

      if (city.isEmpty || city == 'null') {
        debugPrint('Chand: No city selected.');
        return;
      }

      final response = await apiClient.getData(
        Endpoints.HIJRI,
        query: {'city': city},
        cacheDuration: const Duration(minutes: 15),
        offlineFallback: true,
      );

      if (response.statusCode == 200 && response.body is Map) {
        chandData.value = ChandModel.fromJson(
          Map<String, dynamic>.from(response.body),
        );

        debugPrint(
          'Chand data loaded for $city: '
          '${chandData.value?.hijriDay} '
          '${chandData.value?.hijriMonthName} '
          '${chandData.value?.hijriYear}',
        );
      } else {
        debugPrint('Chand API error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching Chand data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
