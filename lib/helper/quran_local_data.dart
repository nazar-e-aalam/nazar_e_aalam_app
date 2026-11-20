import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class QuranLocalData {
  static const supportedLanguages = {'ar', 'en', 'hi', 'guj', 'ur', 'sw'};

  static String get language {
    final code = Get.locale?.languageCode ?? 'en';
    return supportedLanguages.contains(code) ? code : 'en';
  }

  static Future<Map<String, dynamic>> readJson(String path) async {
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List && decoded.length == 1 && decoded.first is Map) {
      return Map<String, dynamic>.from(decoded.first as Map);
    }

    throw FormatException('Invalid Quran JSON: $path');
  }

  static Future<Map<String, dynamic>> surah(int number) {
    if (number < 1 || number > 114) {
      throw RangeError.range(number, 1, 114, 'Surah number');
    }

    return readJson('assets/quran/$language/s00$number.json');
  }

  static Future<Map<String, dynamic>> surahList() {
    return readJson('assets/quran/surah_list.json');
  }

  static Future<Map<String, dynamic>> juzList() {
    return readJson('assets/quran/juzz_list.json');
  }
}
