class MemorableDaysData {
  final List<MemorableMonth> months;
  const MemorableDaysData(this.months);

  factory MemorableDaysData.fromJson(Map<String, dynamic> json) {
    final raw = json['months'];
    if (raw is! List) throw const FormatException('Missing months array');
    return MemorableDaysData(raw.map((item) =>
      MemorableMonth.fromJson(Map<String, dynamic>.from(item as Map))).toList());
  }
}

String localizedValue(Map<String, String> values, String languageCode) {
  final preferred = values[languageCode];
  if (preferred != null && preferred.trim().isNotEmpty) return preferred;
  final fallback = values['gu'] ?? values['en'];
  if (fallback != null && fallback.trim().isNotEmpty) return fallback;
  return values.values.firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');
}

Map<String, String> parseTranslations(dynamic input) {
  if (input is String) return {'gu': input};
  if (input is! Map) return {};
  return input.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
}

class MemorableMonth {
  final int month;
  final String id;
  final Map<String, String> name;
  final Map<String, String> heading;
  final List<MemorableDay> days;

  const MemorableMonth({required this.month, required this.id, required this.name,
    required this.heading, required this.days});

  factory MemorableMonth.fromJson(Map<String, dynamic> json) {
    return MemorableMonth(
      month: (json['month'] as num).toInt(),
      id: (json['id'] ?? 'month_${json['month']}').toString(),
      name: parseTranslations(json['name'] ?? json['title']),
      heading: parseTranslations(json['heading']),
      days: ((json['days'] as List?) ?? []).map((d) =>
        MemorableDay.fromJson(Map<String, dynamic>.from(d as Map))).toList(),
    );
  }
}

class MemorableDay {
  final int? day;
  final List<MemorableEvent> events;
  const MemorableDay({required this.day, required this.events});

  factory MemorableDay.fromJson(Map<String, dynamic> json) {
    final raw = json['events'];
    // Supports the final event-array schema and the older Gujarati draft schema.
    final entries = raw is List
      ? raw.map((e) => MemorableEvent.fromJson(Map<String, dynamic>.from(e as Map))).toList()
      : [MemorableEvent(id: '', description: parseTranslations(json['description']))];
    return MemorableDay(day: (json['day'] as num?)?.toInt(), events: entries);
  }
}

class MemorableEvent {
  final String id;
  final Map<String, String> description;
  const MemorableEvent({required this.id, required this.description});
  factory MemorableEvent.fromJson(Map<String, dynamic> json) => MemorableEvent(
    id: (json['id'] ?? '').toString(),
    description: parseTranslations(json['description']),
  );
}
