import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WazaifData {
  static const assetPath = 'assets/quran/wazaif.json';
  static Future<List<Wazifa>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final items = (json['items'] as List<dynamic>? ?? const []);
    final result = items.map((e) => Wazifa.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  static String get language {
    final code = Get.locale?.languageCode.toLowerCase() ?? 'en';
    return const {'en', 'hi', 'gu', 'ur', 'ar', 'sw'}.contains(code) ? code : 'en';
  }

  static String localized(Map<String, dynamic> values) {
    final current = values[language]?.toString() ?? '';
    if (current.trim().isNotEmpty) return current;
    return (values['en'] ?? values.values.where((v) => v != null && v.toString().trim().isNotEmpty).firstOrNull ?? '').toString();
  }

  static bool get rtl => language == 'ar' || language == 'ur';
}

Map<String, dynamic> _map(dynamic input) => input is Map ? Map<String, dynamic>.from(input) : <String, dynamic>{};

class Wazifa {
  final String id;
  final int order;
  final String category;
  final Map<String, dynamic> title;
  final Map<String, dynamic> description;
  final List<WazifaSection> sections;
  final List<dynamic> references;
  final String reviewStatus;

  Wazifa.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '',
        order = (json['order'] as num?)?.toInt() ?? 0,
        category = json['category']?.toString() ?? '',
        title = _map(json['title']),
        description = _map(json['description']),
        sections = (json['sections'] as List<dynamic>? ?? const [])
            .map((e) => WazifaSection.fromJson(_map(e))).toList(),
        references = json['references'] as List<dynamic>? ?? const [],
        reviewStatus = json['review_status']?.toString() ?? '';

  String get name => WazaifData.localized(title);
  String get summary => WazaifData.localized(description);
}

class WazifaSection {
  final Map<String, dynamic> data;
  WazifaSection.fromJson(this.data);
  String get id => data['id']?.toString() ?? '';
  String get type => data['type']?.toString() ?? '';
  String get arabic => data['arabic_text']?.toString() ?? '';
  String get translation => WazaifData.localized(_map(data['translations']));
  String get transliteration => WazaifData.localized(_map(data['transliterations']));
  String get title => WazaifData.localized(_map(data['title']));
  String get content => WazaifData.localized(_map(data['content'] ?? data['text'] ?? data['description'] ?? data['instructions']));
  int? get count => data['repeat_count'] is num ? (data['repeat_count'] as num).toInt() : null;
  List<dynamic> get referenceIds => data['reference_ids'] as List<dynamic>? ?? const [];
}
