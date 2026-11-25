import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/quran_settings_controller.dart';

class QuranLocalData {
  QuranLocalData._();

  // Actual Quran asset directory names.
  static const Set<String> supportedLanguages = {
    'ar',
    'en',
    'hi',
    'guj',
    'ur',
    'sw',
  };

  static const String defaultLanguage = 'en';

  static const Map<String, String> _languageAliases = {
    'gu': 'guj',
    'hin': 'hi',
  };

  // ==================== LANGUAGE ====================

  static String get language => resolveLanguage();

  static String normalizeLanguage(String language) {
    final normalized = language
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .split('_')
        .first;

    final code = _languageAliases[normalized] ?? normalized;

    return supportedLanguages.contains(code) ? code : defaultLanguage;
  }

  static String resolveLanguage([String? language]) {
    String? selected = language?.trim().toLowerCase();

    if (selected == null || selected.isEmpty) {
      if (Get.isRegistered<SettingsController>()) {
        selected = Get.find<SettingsController>().quranLanguage.value;
      }
    }

    if (selected == null || selected.isEmpty || selected == 'system') {
      selected = Get.locale?.languageCode ?? defaultLanguage;
    }

    return normalizeLanguage(selected);
  }

  static Future<String> resolveLanguageAsync([String? language]) async {
    final explicitLanguage = language?.trim().toLowerCase();

    // Explicit requests don't depend on saved preferences.
    if (explicitLanguage != null &&
        explicitLanguage.isNotEmpty &&
        explicitLanguage != 'system') {
      return normalizeLanguage(explicitLanguage);
    }

    if (Get.isRegistered<SettingsController>()) {
      await Get.find<SettingsController>().quranLanguageReady;
    }

    return resolveLanguage(language);
  }

  static bool isRtlLanguage([String? language]) {
    final resolved = resolveLanguage(language);

    return resolved == 'ar' || resolved == 'ur';
  }

  // ==================== JSON READER ====================

  static Future<Map<String, dynamic>> readJson(String path) async {
    final raw = await rootBundle.loadString(path);

    final decoded = jsonDecode(raw);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List && decoded.length == 1 && decoded.first is Map) {
      return Map<String, dynamic>.from(decoded.first as Map);
    }

    throw FormatException('Invalid Quran JSON structure: $path');
  }

  // ==================== SURAH DETAILS ====================

  static Future<Map<String, dynamic>> surah(
    int number, {
    String? language,
  }) async {
    if (number < 1 || number > 114) {
      throw RangeError.range(number, 1, 114, 'Surah number');
    }

    final resolvedLanguage = await resolveLanguageAsync(language);

    final path = 'assets/quran/$resolvedLanguage/s00$number.json';

    return readJson(path);
  }

  // ==================== SURAH LIST ====================

  static Future<Map<String, dynamic>> surahList({String? language}) {
    // Currently shared across all Quran languages.
    return readJson('assets/quran/surah_list.json');
  }

  // ==================== JUZ LIST ====================

  static Future<Map<String, dynamic>> juzList({String? language}) {
    // Currently shared across all Quran languages.
    return readJson('assets/quran/juzz_list.json');
  }
}
