// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/quran_settings_controller.dart';

import 'package:nazar_e_alam/data/model/response/juz_list_model.dart';
import 'package:nazar_e_alam/data/model/response/offline_sura_model.dart';
import 'package:nazar_e_alam/data/model/response/sura_detile_model.dart';

import 'package:nazar_e_alam/helper/offline_quran_loader.dart';
import 'package:nazar_e_alam/helper/quran_local_data.dart';
import 'package:nazar_e_alam/helper/arabic_utils.dart';

import 'package:nazar_e_alam/view/screens/offline_quran/offline_surah_detail_screen.dart';

class OfflineQuranController extends GetxController {
  // ==================== CONTROLLERS ====================

  SettingsController get settingsController => Get.find<SettingsController>();

  String get currentLanguage => QuranLocalData.resolveLanguage();

  Worker? _languageWorker;

  // ==================== REQUEST TRACKING ====================
  String? _lastResolvedLanguage;
  int _surahListRequestId = 0;
  int _surahDetailsRequestId = 0;
  int _juzListRequestId = 0;
  int _searchRequestId = 0;

  // ==================== INITIALIZATION ====================

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController(), permanent: true);
    }

    _lastResolvedLanguage = currentLanguage;

    _languageWorker = ever<String>(settingsController.quranLanguage, (_) {
      unawaited(refreshQuranLanguage());
    });
  }

  // ==================== SURAH LIST ====================

  final RxBool isLoading = true.obs;

  final RxList<OfflineSurahListModel> surahList = <OfflineSurahListModel>[].obs;

  Future<void> loadSurahList({String? language}) async {
    final requestId = ++_surahListRequestId;
    isLoading.value = true;

    try {
      await settingsController.quranLanguageReady;

      if (isClosed || requestId != _surahListRequestId) {
        return;
      }

      final resolvedLanguage = QuranLocalData.resolveLanguage(language);

      final data = await QuranLocalData.surahList(language: resolvedLanguage);

      if (isClosed || requestId != _surahListRequestId) {
        return;
      }

      final surahData = data['data'] as List;

      surahList.assignAll(
        surahData.map((e) => OfflineSurahListModel.fromJson(e)),
      );
    } catch (e, stackTrace) {
      debugPrint('Error loading offline Surah list: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (!isClosed && requestId == _surahListRequestId) {
        isLoading.value = false;
        update();
      }
    }
  }

  // ==================== SURAH DETAILS ====================

  final RxBool isSurahDetailsLoading = true.obs;

  SuraDetaileModel? suraDetailsApiData;

  int? lastSurahNumber;

  Future<void> loadSurahDetails({
    required int surahNumber,
    String? translatorId,
    String? language,
  }) async {
    if (surahNumber < 1 || surahNumber > 114) {
      debugPrint('Invalid Surah number: $surahNumber');
      return;
    }

    final requestId = ++_surahDetailsRequestId;

    lastSurahNumber = surahNumber;

    isSurahDetailsLoading.value = true;
    suraDetailsApiData = null;

    update();

    try {
      await settingsController.quranLanguageReady;

      if (isClosed || requestId != _surahDetailsRequestId) {
        return;
      }

      final resolvedLanguage = QuranLocalData.resolveLanguage(language);

      final data = await QuranLocalData.surah(
        surahNumber,
        language: resolvedLanguage,
      );

      if (isClosed || requestId != _surahDetailsRequestId) {
        return;
      }

      suraDetailsApiData = SuraDetaileModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('Error loading offline Surah $surahNumber: $e');

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (!isClosed && requestId == _surahDetailsRequestId) {
        isSurahDetailsLoading.value = false;
        update();
      }
    }
  }

  // ==================== CHANGE SURAH ====================

  void changeSurah(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) {
      return;
    }

    lastSurahNumber = surahNumber;

    unawaited(loadSurahDetails(surahNumber: surahNumber));

    Future.microtask(() {
      if (isClosed) return;

      Get.to(
        () => OfflineSuraDetaileScreen(
          appBackButton: true,
          surahNumber: surahNumber.toString(),
        ),
        arguments: 0,
      );
    });
  }

  // ==================== JUZ LIST ====================

  final RxBool isJuzzLoading = true.obs;

  JuzListModel? juzListApiData;

  Future<void> loadJuzzList({String? language}) async {
    final requestId = ++_juzListRequestId;
    isJuzzLoading.value = true;

    try {
      await settingsController.quranLanguageReady;

      if (isClosed || requestId != _juzListRequestId) {
        return;
      }

      final resolvedLanguage = QuranLocalData.resolveLanguage(language);

      final data = await QuranLocalData.juzList(language: resolvedLanguage);

      if (isClosed || requestId != _juzListRequestId) {
        return;
      }

      juzListApiData = JuzListModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('Error loading offline Juz list: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (!isClosed && requestId == _juzListRequestId) {
        isJuzzLoading.value = false;
        update();
      }
    }
  }

  // ==================== SEARCH STATE ====================

  final verses = <Map<String, dynamic>>[].obs;

  final results = <Map<String, dynamic>>[].obs;

  final RxBool isQuranSearching = false.obs;

  final RxnString searchError = RxnString();

  String? _searchLanguage;

  String _lastSearchQuery = '';

  bool _searchInitialized = false;

  // ==================== INITIALIZE SEARCH ====================

  Future<void> initLoader({String? language}) async {
    final requestId = ++_searchRequestId;

    _searchInitialized = true;

    isQuranSearching.value = true;
    searchError.value = null;

    try {
      await settingsController.quranLanguageReady;

      if (isClosed || requestId != _searchRequestId) {
        return;
      }

      final resolvedLanguage = QuranLocalData.resolveLanguage(language);

      if (_searchLanguage != resolvedLanguage) {
        verses.clear();
        results.clear();
        _searchLanguage = null;
      }

      final loadedVerses = await QuranLoader.instance.loadAllVerses(
        language: resolvedLanguage,
      );

      if (isClosed || requestId != _searchRequestId) {
        return;
      }

      verses.assignAll(loadedVerses);

      _searchLanguage = resolvedLanguage;

      // Re-run the existing search in the new language.
      if (_lastSearchQuery.isNotEmpty) {
        _filterVerses(_lastSearchQuery);
      }
    } catch (e, stackTrace) {
      if (isClosed || requestId != _searchRequestId) {
        return;
      }

      searchError.value = e.toString();

      debugPrint('Error initializing Quran search: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (!isClosed && requestId == _searchRequestId) {
        isQuranSearching.value = false;
        update();
      }
    }
  }

  // ==================== SEARCH ====================

  void search(String q) {
    _lastSearchQuery = q.trim();

    if (_lastSearchQuery.isEmpty) {
      results.clear();
      return;
    }

    // Prevent searching translations from an old language.
    if (_searchLanguage != currentLanguage) {
      results.clear();

      if (!isQuranSearching.value) {
        unawaited(initLoader());
      }

      return;
    }

    _filterVerses(_lastSearchQuery);
  }

  void _filterVerses(String input) {
    final query = removeDiacritics(input.trim().toLowerCase());

    if (query.isEmpty) {
      results.clear();
      return;
    }

    final filtered = verses.where((v) {
      final arabic = removeDiacritics(
        (v['arabic_name'] ?? '').toString(),
      ).toLowerCase();

      final noTashkeel = removeDiacritics(
        (v['text_without_taskeel'] ?? '').toString(),
      ).toLowerCase();

      final translated = removeDiacritics(
        (v['translated_name'] ?? '').toString(),
      ).toLowerCase();

      final chapter = v['chapter'];

      final chapterName = removeDiacritics(
        chapter is Map ? (chapter['arabic_name'] ?? '').toString() : '',
      ).toLowerCase();

      return arabic.contains(query) ||
          noTashkeel.contains(query) ||
          translated.contains(query) ||
          chapterName.contains(query);
    }).toList();

    results.assignAll(filtered);

    debugPrint(
      'Quran search ($_searchLanguage): '
      '${filtered.length} results',
    );
  }

  void clearSearch() {
    _lastSearchQuery = '';

    results.clear();
    searchError.value = null;

    update();
  }

  // ==================== LANGUAGE REFRESH ====================

  Future<void> refreshQuranLanguage({String? language}) async {
    try {
      final resolvedLanguage = await QuranLocalData.resolveLanguageAsync(
        language,
      );

      if (isClosed) return;

      if (_lastResolvedLanguage == resolvedLanguage) {
        return;
      }

      _lastResolvedLanguage = resolvedLanguage;

      final activeSurah = lastSurahNumber;
      final refreshSearch = _searchInitialized;

      // Invalidate only language-dependent requests.
      _surahDetailsRequestId++;
      _searchRequestId++;

      suraDetailsApiData = null;

      verses.clear();
      results.clear();

      _searchLanguage = null;
      searchError.value = null;

      isSurahDetailsLoading.value = activeSurah != null;

      isQuranSearching.value = refreshSearch;

      update();

      await Future.wait<void>([
        if (activeSurah != null)
          loadSurahDetails(
            surahNumber: activeSurah,
            language: resolvedLanguage,
          ),

        if (refreshSearch) initLoader(language: resolvedLanguage),
      ]);
    } catch (e, stackTrace) {
      debugPrint('Error refreshing Quran language: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  // ==================== DISPOSE ====================

  @override
  void onClose() {
    _languageWorker?.dispose();

    _surahListRequestId++;
    _surahDetailsRequestId++;
    _juzListRequestId++;
    _searchRequestId++;

    super.onClose();
  }
}
