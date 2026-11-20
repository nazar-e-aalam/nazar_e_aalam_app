import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/memorable_days_model.dart';

class MemorableDaysLocalService {
  static const assetPath = 'assets/memorable_days/memorable_days.json';
  static Future<MemorableDaysData>? _cached;

  static Future<MemorableDaysData> load() => _cached ??= _load();

  static Future<MemorableDaysData> _load() async {
    final content = await rootBundle.loadString(assetPath);
    final json = jsonDecode(content);
    if (json is! Map) throw const FormatException('Invalid Memorable Days JSON');
    return MemorableDaysData.fromJson(Map<String, dynamic>.from(json));
  }

  static void clearCache() => _cached = null;
}
