
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nazar_e_alam/data/model/mubarak_name_model.dart';

enum MubarakNamesCategory {
  allah,
  muhammad,
  ghaus,
}

extension MubarakNamesCategoryExtension on MubarakNamesCategory {
  String get assetPath {
    switch (this) {
      case MubarakNamesCategory.allah:
        return 'assets/names/sifat_names.json';
      case MubarakNamesCategory.muhammad:
        return 'assets/names/muhammad_names.json';
      case MubarakNamesCategory.ghaus:
        return 'assets/names/ghaus_names.json';
    }
  }

  int get expectedCount {
    switch (this) {
      case MubarakNamesCategory.allah:
      case MubarakNamesCategory.muhammad:
        return 99;
      case MubarakNamesCategory.ghaus:
        return 11;
    }
  }
}

class MubarakNamesRepository {
  Future<List<MubarakName>> load(
    MubarakNamesCategory category,
  ) async {
    final source = await rootBundle.loadString(category.assetPath);
    final decoded = jsonDecode(source);

    if (decoded is! List) {
      throw const FormatException(
        'Mubarak Names JSON must contain a list.',
      );
    }

    final names = decoded.map((item) {
      return MubarakName.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();

    if (names.length != category.expectedCount) {
      throw FormatException(
        'Expected ${category.expectedCount} names, '
        'found ${names.length} in ${category.assetPath}',
      );
    }

    final ids = names.map((name) => name.id).toSet();
    if (ids.length != names.length) {
      throw const FormatException('Duplicate Mubarak Name IDs.');
    }

    return List.unmodifiable(names);
  }
}
