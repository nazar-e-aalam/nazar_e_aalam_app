import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/quran_settings_controller.dart';

import 'package:nazar_e_alam/data/model/response/juz_list_model.dart';
import 'package:nazar_e_alam/data/model/response/sifat_name_details_model.dart';
import 'package:nazar_e_alam/data/model/response/sifat_name_list_model.dart';
import 'package:nazar_e_alam/data/model/response/sura_detile_model.dart';
import 'package:nazar_e_alam/data/model/response/sura_list_model.dart';

import 'package:nazar_e_alam/helper/quran_local_data.dart';

class QuranController extends GetxController implements GetxService {
  QuranController();

  // ==================== MODELS ====================

  SuraListModel? suraListApiData;
  SuraDetaileModel? suraDetaileApiData;
  JuzListModel? juzListApiData;

  SifatNameListModel? sifatNameApiData;
  SifatNameDetailsModel? sifatnameDetailsApidata;

  // ==================== LOADING STATES ====================

  final RxBool isSifatNameListLoading = false.obs;
  final RxBool isSifatNameDetailsLoading = false.obs;

  final RxBool isJuzListLoading = false.obs;
  final RxBool isSuraListLoading = false.obs;
  final RxBool isSuraDetaileLoading = false.obs;

  final RxBool isLanguageChanging = false.obs;

  final RxnString surahDetailError = RxnString();

  int? suraNumber;

  // ==================== REQUEST TRACKING ====================

  int _surahListRequestId = 0;
  int _juzListRequestId = 0;
  int _surahDetailRequestId = 0;

  // ==================== LANGUAGE ====================

  SettingsController get settingsController => Get.find<SettingsController>();

  String get currentLanguage => QuranLocalData.resolveLanguage();

  String resolveLanguage([String? language]) =>
      QuranLocalData.resolveLanguage(language);

  Future<String> resolveLanguageAsync([String? language]) =>
      QuranLocalData.resolveLanguageAsync(language);

  // ==================== CHANGE LANGUAGE ====================

  Future<void> changeQuranLanguage(String language) async {
    if (isClosed || isLanguageChanging.value) {
      return;
    }

    isLanguageChanging.value = true;

    try {
      if (!Get.isRegistered<SettingsController>()) {
        Get.put<SettingsController>(SettingsController(), permanent: true);
      }

      final settings = settingsController;

      await settings.quranLanguageReady;

      if (isClosed) return;

      final normalized = settings.normalizeQuranPreference(language);

      if (!settings.isValidQuranLanguage(normalized)) {
        throw ArgumentError('Unsupported Quran language: $language');
      }

      final previousLanguage = currentLanguage;

      debugPrint('[Quran] Previous language: $previousLanguage');

      if (settings.quranLanguage.value != normalized) {
        await settings.changeQuranLanguage(normalized);
      }

      if (isClosed) return;

      final newLanguage = await resolveLanguageAsync();

      debugPrint('[Quran] New language: $newLanguage');

      if (previousLanguage != newLanguage || surahDetailError.value != null) {
        await refreshQuranData(language: newLanguage);
      }

      debugPrint('[Quran] Language change completed');
    } catch (e, stackTrace) {
      debugPrint('[Quran] Language change failed: $e');

      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    } finally {
      if (!isClosed) {
        isLanguageChanging.value = false;
        update();
      }
    }
  }

  // ==================== REFRESH QURAN ====================

  Future<void> refreshQuranData({String? language}) async {
    final resolvedLanguage = await resolveLanguageAsync(language);

    if (isClosed) return;

    final activeSurah = suraNumber;

    // Invalidate previous Surah detail requests.
    _surahDetailRequestId++;

    suraDetaileApiData = null;
    surahDetailError.value = null;

    isSuraDetaileLoading.value = activeSurah != null;

    update();

    // Surah and Juz metadata are shared across languages.
    // Only reload the language-dependent Surah details.
    if (activeSurah != null) {
      await fetchSuraDetaileData(
        suraId: activeSurah.toString(),
        language: resolvedLanguage,
        throwOnError: true,
      );
    }
  }

  // ==================== SURAH LIST ====================

  Future<void> fetchSuraListData({
    String? translatorId,
    String? language,
  }) async {
    if (isClosed) return;

    final requestId = ++_surahListRequestId;

    isSuraListLoading.value = true;
    update();

    try {
      final data = await QuranLocalData.surahList(language: language);

      if (isClosed || requestId != _surahListRequestId) {
        return;
      }

      suraListApiData = SuraListModel.fromJson(data);

      debugPrint('[Quran] Surah list loaded');
    } catch (e, stackTrace) {
      debugPrint('[Quran] Surah list error: $e');

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (!isClosed && requestId == _surahListRequestId) {
        isSuraListLoading.value = false;
        update();
      }
    }
  }

  // ==================== SURAH DETAILS ====================

  Future<void> fetchSuraDetaileData({
    String? suraId,
    String? translatorId,
    String? language,
    bool throwOnError = false,
  }) async {
    if (isClosed || isSuraListLoading.value) return;

    final surahNumber = suraId == null ? suraNumber : int.tryParse(suraId);

    if (surahNumber == null || surahNumber < 1 || surahNumber > 114) {
      final error = ArgumentError('Invalid Surah number: $suraId');

      debugPrint('[Quran] $error');

      if (throwOnError) throw error;

      return;
    }

    final requestId = ++_surahDetailRequestId;

    suraNumber = surahNumber;

    isSuraDetaileLoading.value = true;
    suraDetaileApiData = null;
    surahDetailError.value = null;

    update();

    try {
      final resolvedLanguage = await resolveLanguageAsync(language);

      if (isClosed || requestId != _surahDetailRequestId) {
        return;
      }

      debugPrint(
        '[Quran] Loading Surah $surahNumber '
        '($resolvedLanguage)',
      );

      final data = await QuranLocalData.surah(
        surahNumber,
        language: resolvedLanguage,
      );

      if (isClosed || requestId != _surahDetailRequestId) {
        return;
      }

      suraDetaileApiData = SuraDetaileModel.fromJson(data);

      debugPrint(
        '[Quran] Surah $surahNumber loaded '
        '($resolvedLanguage)',
      );
    } catch (e, stackTrace) {
      if (isClosed || requestId != _surahDetailRequestId) {
        return;
      }

      surahDetailError.value = e.toString();

      debugPrint('[Quran] Surah $surahNumber error: $e');

      debugPrintStack(stackTrace: stackTrace);

      if (throwOnError) rethrow;
    } finally {
      if (!isClosed && requestId == _surahDetailRequestId) {
        isSuraDetaileLoading.value = false;
        update();
      }
    }
  }

  // ==================== JUZ LIST ====================

  Future<void> fetchJuzListData({
    String? translatorId,
    String? language,
  }) async {
    if (isClosed || isJuzListLoading.value) return;

    final requestId = ++_juzListRequestId;

    isJuzListLoading.value = true;
    update();

    try {
      final data = await QuranLocalData.juzList(language: language);

      if (isClosed || requestId != _juzListRequestId) {
        return;
      }

      juzListApiData = JuzListModel.fromJson(data);

      debugPrint('[Quran] Juz list loaded');
    } catch (e, stackTrace) {
      debugPrint('[Quran] Juz list error: $e');

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (!isClosed && requestId == _juzListRequestId) {
        isJuzListLoading.value = false;
        update();
      }
    }
  }

  // ==================== DISPOSE ====================

  @override
  void onClose() {
    _surahListRequestId++;
    _juzListRequestId++;
    _surahDetailRequestId++;

    super.onClose();
  }
}
