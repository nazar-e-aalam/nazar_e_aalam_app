import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/dua_book_model.dart';

class DuaBookRepository {
  Future<DuaBook> load() async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/quran/dua.json'))
            as Map<String, dynamic>;
    if (data['module'] != 'dua_book' || data['schema_version'] != 1) {
      throw const FormatException('Unsupported Dua Book dataset');
    }
    return DuaBook(data);
  }
}
