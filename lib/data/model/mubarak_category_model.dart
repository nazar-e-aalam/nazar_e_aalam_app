
class MubarakCategoryEntry {
  final String id;
  final int? number;
  final int order;
  final String type;
  final Map<String, String> text;

  const MubarakCategoryEntry({
    required this.id,
    required this.number,
    required this.order,
    required this.type,
    required this.text,
  });

  factory MubarakCategoryEntry.fromJson(
    Map<String, dynamic> json, {
    required int fallbackOrder,
  }) {
    final rawNumber = json['number'];
    final rawOrder = json['order'];

    return MubarakCategoryEntry(
      id: json['id'].toString(),
      number: rawNumber is num ? rawNumber.toInt() : null,
      order: rawOrder is num ? rawOrder.toInt() : fallbackOrder,
      type: (json['type'] ?? 'entry').toString(),
      text: MubarakCategory.localizedMap(json['text']),
    );
  }

  bool get isHeading => type == 'heading';

  bool get isParagraph => type == 'paragraph';

  bool get isNumberedEntry => type == 'entry' && number != null;

  String localized(String language) =>
      MubarakCategory.pick(text, language);
}


class MubarakCategory {
  final String id;
  final int number;
  final Map<String, String> title;
  final Map<String, String> heading;
  final List<MubarakCategoryEntry> entries;

  const MubarakCategory({
    required this.id,
    required this.number,
    required this.title,
    required this.heading,
    required this.entries,
  });

  static const languages = {
    'en',
    'gu',
    'hi',
    'sw',
    'ar',
    'ur',
  };

  static Map<String, String> localizedMap(dynamic value) {
    if (value is! Map) {
      throw const FormatException(
        'Expected a language map',
      );
    }

    final result = <String, String>{};

    for (final lang in languages) {
      final text = value[lang];

      if (text is! String || text.trim().isEmpty) {
        throw FormatException(
          'Missing or empty translation for $lang',
        );
      }

      result[lang] = text;
    }

    return Map.unmodifiable(result);
  }

  static String pick(
    Map<String, String> values,
    String language,
  ) {
    final normalized = language == 'guj'
        ? 'gu'
        : language;

    return values[normalized] ??
        values['gu'] ??
        values['en'] ??
        '';
  }

  factory MubarakCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['entries'];

    if (raw is! List) {
      throw const FormatException(
        'Category entries must be a list',
      );
    }

    final entries = <MubarakCategoryEntry>[];

    for (var index = 0; index < raw.length; index++) {
      final entry = Map<String, dynamic>.from(
        raw[index] as Map,
      );

      entries.add(
        MubarakCategoryEntry.fromJson(
          entry,
          fallbackOrder: index + 1,
        ),
      );
    }

    entries.sort(
      (a, b) => a.order.compareTo(b.order),
    );

    return MubarakCategory(
      id: json['id'].toString(),
      number: (json['number'] as num).toInt(),
      title: localizedMap(json['title']),
      heading: localizedMap(json['heading']),
      entries: List.unmodifiable(entries),
    );
  }

  String localizedTitle(String language) =>
      pick(title, language);

  String localizedHeading(String language) =>
      pick(heading, language);
}
