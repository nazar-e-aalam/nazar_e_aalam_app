import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:nazar_e_alam/data/model/mubarak_category_model.dart';

class MubarakCategoriesRepository {
  static const assetPath = 'assets/names/mubarak_names.json';
  static Future<List<MubarakCategory>>? _cached;

  Future<List<MubarakCategory>> load() => _cached ??= _read();

  static Future<List<MubarakCategory>> _read() async {
    final decoded = jsonDecode(await rootBundle.loadString(assetPath));
    if (decoded is! Map || decoded['categories'] is! List) {
      throw const FormatException('Expected an object containing categories');
    }
    final categories =
        (decoded['categories'] as List)
            .map(
              (item) => MubarakCategory.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList()
          ..sort((a, b) => a.number.compareTo(b.number));
    if (categories.length != 12) {
      throw FormatException(
        'Expected 12 Mubarak Naam categories; found ${categories.length}',
      );
    }
    if (categories.map((e) => e.id).toSet().length != categories.length ||
        categories.map((e) => e.number).toSet().length != categories.length) {
      throw const FormatException('Duplicate category ID or number');
    }
    for (final category in categories) {
      if (category.entries.map((e) => e.id).toSet().length !=
          category.entries.length) {
        throw FormatException('Duplicate entry IDs in ${category.id}');
      }
    }
    return List.unmodifiable(categories);
  }

  static void clearCache() => _cached = null;
}
