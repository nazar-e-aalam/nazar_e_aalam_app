class FatehaDocument {
  final String id;
  final String defaultLanguage;
  final List<String> supportedLanguages;
  final Map<String, String> title;
  final List<FatehaSection> sections;

  const FatehaDocument({required this.id, required this.defaultLanguage,
    required this.supportedLanguages, required this.title, required this.sections});

  factory FatehaDocument.fromJson(Map<String, dynamic> json) {
    final sections = (json['sections'] as List).map((value) =>
      FatehaSection.fromJson(Map<String, dynamic>.from(value as Map))).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return FatehaDocument(
      id: json['id'] as String,
      defaultLanguage: json['default_language'] as String? ?? 'gu',
      supportedLanguages: List<String>.from(json['supported_languages'] as List),
      title: fatehaLanguageMap(json['title']),
      sections: List.unmodifiable(sections),
    );
  }
  String localizedTitle(String language) => fatehaLocalize(title, language, defaultLanguage);
}

class FatehaSection {
  final String id;
  final int order;
  final Map<String, String> title;
  final List<FatehaItem> items;
  const FatehaSection({required this.id, required this.order, required this.title, required this.items});

  factory FatehaSection.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List).map((value) =>
      FatehaItem.fromJson(Map<String, dynamic>.from(value as Map))).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return FatehaSection(id: json['id'] as String, order: (json['order'] as num).toInt(),
      title: fatehaLanguageMap(json['title']), items: List.unmodifiable(items));
  }
  String localizedTitle(String language, String fallback) => fatehaLocalize(title, language, fallback);
}

class FatehaItem {
  final String id;
  final int order;
  final String type;
  final Map<String, String> text;
  final int? repeatCount;
  final Map<String, dynamic>? reference;
  final dynamic placeholder;
  const FatehaItem({required this.id, required this.order, required this.type,
    required this.text, this.repeatCount, this.reference, this.placeholder});

  factory FatehaItem.fromJson(Map<String, dynamic> json) => FatehaItem(
    id: json['id'] as String,
    order: (json['order'] as num).toInt(),
    type: json['type'] as String? ?? 'recitation',
    text: fatehaLanguageMap(json['text']),
    repeatCount: (json['repeat_count'] as num?)?.toInt(),
    reference: json['reference'] is Map
      ? Map<String, dynamic>.from(json['reference'] as Map) : null,
    placeholder: json['placeholder'],
  );
  String localizedText(String language, String fallback) => fatehaLocalize(text, language, fallback);
}

Map<String, String> fatehaLanguageMap(dynamic value) {
  if (value is! Map) throw const FormatException('Expected translated language map');
  return Map.unmodifiable(value.map((key, value) => MapEntry(key.toString(), value.toString())));
}

String fatehaLocalize(Map<String, String> values, String language, String fallback) {
  final code = language == 'guj' ? 'gu' : language.toLowerCase().split(RegExp('[-_]')).first;
  return values[code] ?? values[fallback] ?? values['gu'] ?? values['en'] ?? '';
}
