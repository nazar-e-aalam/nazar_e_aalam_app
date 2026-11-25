import 'package:flutter/widgets.dart';

typedef Json = Map<String, dynamic>;
String duaLanguage(String? code) => switch (code) {
  'guj' => 'gu',
  'hin' => 'hi',
  'ara' => 'ar',
  'ur' => 'ur',
  'ar' => 'ar',
  'gu' => 'gu',
  'hi' => 'hi',
  'sw' => 'sw',
  _ => 'en',
};
String localized(dynamic value, String lang) {
  if (value is! Map) return '';
  return (value[lang] ?? value['en'] ?? '').toString();
}

TextDirection duaDirection(String lang) =>
    ['ar', 'ur'].contains(lang) ? TextDirection.rtl : TextDirection.ltr;

class DuaItem {
  final Json data;
  DuaItem(this.data);
  String get id => data['id'] as String;
  String get type => data['type'] as String;
  bool get recitation => type == 'recitation';
  String get arabic => data['arabic'] as String? ?? '';
  int? get repeat => data['repeat_count'] as int?;
  String title(String lang) => localized(data['title'], lang);
  String text(String lang) => localized(data['text'], lang);
  String meaning(String lang) => localized(data['translation'], lang);
  String pronunciation(String lang) =>
      lang == 'ar' ? '' : localized(data['transliteration'], lang);
  bool matches(String query) => [
    arabic,
    for (final key in ['title', 'text', 'translation', 'transliteration'])
      if (data[key] is Map) ...(data[key] as Map).values.whereType<String>(),
  ].any((v) => v.toLowerCase().contains(query));
}

class DuaSection {
  final Json data;
  final List<DuaItem> items;
  DuaSection(this.data)
    : items = (data['items'] as List)
          .map((e) => DuaItem(Map<String, dynamic>.from(e as Map)))
          .toList();
  String get id => data['id'] as String;
  String title(String lang) => localized(data['title'], lang);
}

class DuaCategory {
  final Json data;
  final List<DuaSection> sections;
  DuaCategory(this.data)
    : sections = (data['sections'] as List)
          .map((e) => DuaSection(Map<String, dynamic>.from(e as Map)))
          .toList();
  String title(String lang) => localized(data['title'], lang);
  String description(String lang) => localized(data['description'], lang);
}

class DuaBook {
  final Json data;
  final List<DuaCategory> categories;
  DuaBook(this.data)
    : categories = (data['categories'] as List)
          .map((e) => DuaCategory(Map<String, dynamic>.from(e as Map)))
          .toList();
  List<DuaSection> get sections =>
      categories.expand((c) => c.sections).toList();
  String title(String lang) => localized(data['title'], lang);
}
