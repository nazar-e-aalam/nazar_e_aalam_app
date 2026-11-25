import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/fateha_model.dart';

class FatehaRepository {
  static const assetPath = 'assets/quran/fateha_ka_tarika.json';
  static Future<FatehaDocument>? _cached;

  Future<FatehaDocument> load() =>
      _cached ??= _load().catchError((Object error, StackTrace stack) {
        _cached = null;
        Error.throwWithStackTrace(error, stack);
      });

  static void clearCache() => _cached = null;

  Future<FatehaDocument> _load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Fateha JSON root must be an object');
    }
    return FatehaDocument.fromJson(Map<String, dynamic>.from(decoded));
  }
}
