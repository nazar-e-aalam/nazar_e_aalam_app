
class KalimaModel {
  final int id;
  final int position;
  final Map<String, String> title;
  final String arabicText;
  final Map<String, String> translation;

  const KalimaModel({
    required this.id,
    required this.position,
    required this.title,
    required this.arabicText,
    required this.translation,
  });

  factory KalimaModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> readLanguages(dynamic value) {
      if (value is! Map) return {};

      return value.map(
        (key, value) => MapEntry(
          key.toString(),
          value?.toString() ?? '',
        ),
      );
    }

    return KalimaModel(
      id: (json['id'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      title: readLanguages(json['title']),
      arabicText: json['arabic_text']?.toString() ?? '',
      translation: readLanguages(json['translation']),
    );
  }

  String localizedTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? '';
  }

  String localizedTranslation(String languageCode) {
    final value = translation[languageCode];

    if (value != null && value.isNotEmpty) {
      return value;
    }

    return translation['en'] ?? '';
  }
}
