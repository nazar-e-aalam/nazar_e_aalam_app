// dhikr_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/model/response/dikir_details_model.dart';
import 'package:nazar_e_alam/data/model/response/dikir_list_model.dart';
import 'package:nazar_e_alam/data/model/response/local_dhikr_model.dart';
import 'package:nazar_e_alam/data/repository/dikir_list_repo.dart';

class DhikrController extends GetxController implements GetxService {
  final DhikrRepo dhikrRepo;
  DhikrController({required this.dhikrRepo});

  var count = 0.obs;
  var dhikrList = <LocalDhikrModel>[].obs;
  String? localDhikrId;

  Future<void> localLoadCount(String dhikrId) async {
    int loadedCount = await LocalDhikrStorage.getDhikrCount(dhikrId);
    count.value = loadedCount;
  }

  Future<void> localIncrementCount(String dhikrId) async {
    await LocalDhikrStorage.incrementDhikrCount(dhikrId);
    await localLoadCount(dhikrId);
  }

  Future<void> localDeleteCount(String dhikrId) async {
    await LocalDhikrStorage.deleteDhikrCount(dhikrId);
    count.value = 0;
  }

  void localDeleteDhikr(String dhikrId) {
    dhikrList.removeWhere((dhikr) => dhikr.id == dhikrId);
    LocalDhikrStorage.saveDhikrList(dhikrList);
  }

  void localAddDhikr(
    String englishName,
    String arabicName,
    String englishDescription,
    String arabicDescription,
  ) {
    final dhikrId = DateTime.now().millisecondsSinceEpoch.toString();
    dhikrList.add(
      LocalDhikrModel(
        id: dhikrId,
        englishName: englishName,
        arabicName: arabicName,
        englishDescription: englishDescription,
        arabicDescription: arabicDescription,
      ),
    );

    LocalDhikrStorage.saveDhikrList(dhikrList);
  }

  void localLoadDhikrList() {
    LocalDhikrStorage.loadDhikrList().then((savedList) {
      dhikrList.assignAll(savedList);
    });
  }

  ////////////////////////////////////////////
  // local variable
  RxBool isDikirDetailsLoading = false.obs;
  DikirDetailsModel? dikirDetailApiData;

  RxBool isDikirListLoading = false.obs;
  DikirListModel? dikirListApiData;

  // get dua list form here

  Future<void> fetchDikirListData() async {
    isDikirListLoading.value = true;
    update();

    try {
      final response = await dhikrRepo.getDikirListRepo();

      if (response.statusCode == 200) {
        dikirListApiData = DikirListModel.fromJson(
          Map<String, dynamic>.from(response.body as Map),
        );
      } else {
        dikirListApiData = null;
        debugPrint('Dhikr list HTTP error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      dikirListApiData = null;
      debugPrint('Dhikr list error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isDikirListLoading.value = false;
      update();
    }
  }

  Future<void> fetchDikirDetailsData({String? dikirId}) async {
    final id = int.tryParse(dikirId ?? '');

    if (id == null || id < 1) {
      debugPrint('Invalid Dhikr ID: $dikirId');
      dikirDetailApiData = null;
      isDikirDetailsLoading.value = false;
      update();
      return;
    }

    isDikirDetailsLoading.value = true;
    dikirDetailApiData = null;
    update();

    try {
      final response = await dhikrRepo.getDikirDetailsRepo(id.toString());

      if (response.statusCode == 200) {
        dikirDetailApiData = DikirDetailsModel.fromJson(
          Map<String, dynamic>.from(response.body as Map),
        );
      } else {
        debugPrint('Dhikr details HTTP error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Dhikr details error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isDikirDetailsLoading.value = false;
      update();
    }
  }

  // get dua details function

  ////////////////////////////////////////////

  String? dikirId;

  Future<void> loadCount(String dhikrId) async {
    int loadedCount = await LocalStorage.getDhikrCount(dhikrId);
    count.value = loadedCount;
  }

  Future<void> incrementCount(String dhikrId) async {
    await LocalStorage.incrementDhikrCount(dhikrId);
    await loadCount(dhikrId);
  }

  Future<void> deleteCount(String dhikrId) async {
    await LocalStorage.deleteDhikrCount(dhikrId);
    count.value = 0;
  }
}

class LocalDhikrStorage {
  static const dhikrListKey = 'dhikr_list';

  static Future<int> getDhikrCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(dhikrId) ?? 0;
  }

  static Future<void> incrementDhikrCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(dhikrId) ?? 0;
    count++;
    prefs.setInt(dhikrId, count);
  }

  static Future<void> deleteDhikrCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(dhikrId);
  }

  static Future<void> saveDhikrList(List<LocalDhikrModel> dhikrList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      dhikrList.map((dhikr) => dhikr.toJson()).toList(),
    );
    prefs.setString(dhikrListKey, jsonString);
  }

  static Future<List<LocalDhikrModel>> loadDhikrList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(dhikrListKey);
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((item) => LocalDhikrModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }
}

class LocalStorage {
  static Future<int> getDhikrCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(dhikrId) ?? 0;
  }

  static Future<void> incrementDhikrCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(dhikrId) ?? 0;
    count++;
    prefs.setInt(dhikrId, count);
  }

  static Future<void> deleteDhikrCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(dhikrId);
  }
}
