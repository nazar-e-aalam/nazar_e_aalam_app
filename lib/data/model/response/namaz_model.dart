typedef Json = Map<String, dynamic>;
String namazLanguage(String? code) {
  final value = code?.toLowerCase().split(RegExp('[-_]')).first;
  return const {'hin': 'hi', 'guj': 'gu'}[value] ??
      (const ['en', 'hi', 'gu', 'ur', 'ar', 'sw'].contains(value)
          ? value!
          : 'en');
}

String localized(dynamic value, String lang) {
  if (value is! Map) return '';
  return (value[lang] ?? value['en'] ?? '').toString();
}

class NamazSection {
  final Json data;
  NamazSection(this.data);
  String get id => data['id'] as String;
  String get type => data['type'] as String;
  int get order => data['order'] as int;
  String get arabic => data['arabic_text'] as String? ?? '';
  String text(String key, String lang) => localized(data[key], lang);
  List<String> get referenceIds =>
      List<String>.from(data['reference_ids'] ?? []);
  List<String> conditions(String lang) => (data['conditions'] as List? ?? [])
      .map((e) => localized(e, lang))
      .toList();
  int? count(String key) => data[key] as int?;
  String? get externalTarget => data['external_target'] as String?;
}

class NamazItem {
  final Json data;
  late final List<NamazSection> sections =
      (data['sections'] as List)
          .map((e) => NamazSection(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  NamazItem(this.data);
  String get id => data['id'] as String;
  int get order => data['order'] as int;
  String title(String lang) => localized(data['title'], lang);
  String description(String lang) => localized(data['description'], lang);
  bool get needsReview => data['review_status'] != 'verified';
  List<Json> get references => (data['references'] as List? ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
}
