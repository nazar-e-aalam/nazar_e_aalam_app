
import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/kalima_model.dart';

class KalimaLocalService {
  KalimaLocalService._();

  static const String assetPath =
      'assets/quran/kailma_sharif.json';

  static Future<List<KalimaModel>>? _cachedRequest;

  static Future<List<KalimaModel>> getKalimas() {
    return _cachedRequest ??= _loadKalimas().catchError(
      (Object error) {
        _cachedRequest = null;
        throw error;
      },
    );
  }

  static Future<List<KalimaModel>> _loadKalimas() async {
    final content = await rootBundle.loadString(assetPath);

    final decoded = jsonDecode(content) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>;

    final kalimas = items
        .map(
          (item) => KalimaModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    kalimas.sort((a, b) => a.position.compareTo(b.position));

    return List.unmodifiable(kalimas);
  }
}
