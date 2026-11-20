class MubarakName {
  final int id;
  final Map<String, String> names;
  final Map<String, String> meanings;
  final Map<String, String> benefits;
  final String? honorific;

  const MubarakName({
    required this.id,
    required this.names,
    required this.meanings,
    required this.benefits,
    this.honorific,
  });

  static const supportedLanguages = {'en', 'hi', 'guj', 'ar', 'sw', 'ur'};

  factory MubarakName.fromJson(Map<String, dynamic> json) {
    final rawMeanings = json['meanings'];
    final rawBenefits = json['name_benefits'];

    final meaningMap = rawMeanings is Map
        ? Map<String, dynamic>.from(rawMeanings)
        : <String, dynamic>{};

    final benefitsMap = rawBenefits is Map
        ? Map<String, dynamic>.from(rawBenefits)
        : <String, dynamic>{};

    final names = <String, String>{};
    final meanings = <String, String>{};
    final benefits = <String, String>{};

    for (final language in supportedLanguages) {
      names[language] = (json['${language}_name'] ?? '').toString().trim();

      meanings[language] = (meaningMap[language] ?? '').toString().trim();

      benefits[language] = (benefitsMap[language] ?? '').toString().trim();
    }

    return MubarakName(
      id: (json['id'] as num).toInt(),
      names: names,
      meanings: meanings,
      benefits: benefits,
      honorific: json['honorific']?.toString(),
    );
  }

  String _localized(Map<String, String> values, String language) {
    final value = values[language];

    if (value != null && value.isNotEmpty) {
      return value;
    }

    return values['en'] ?? '';
  }

  String name(String language) => _localized(names, language);

  String meaning(String language) => _localized(meanings, language);

  String nameBenefits(String language) => _localized(benefits, language);

  String get arabicName => name('ar');
}
