class DikirListModel {
  bool? status;
  String? message;
  List<Data>? data;

  int total;
  int skip;
  int limit;
  int pages;

  DikirListModel({
    this.status,
    this.message,
    this.data,
    this.total = 0,
    this.skip = 0,
    this.limit = 50,
    this.pages = 0,
  });

  factory DikirListModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] ?? json['data'] ?? [];
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'])
        : <String, dynamic>{};

    return DikirListModel(
      status: json['status'] ?? true,
      message: json['message'],
      data: (items as List)
          .map((item) => Data.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      total: _toInt(meta['total']),
      skip: _toInt(meta['skip']),
      limit: _toInt(meta['limit'], 50),
      pages: _toInt(meta['pages']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': data?.map((item) => item.toJson()).toList() ?? [],
    'meta': {'total': total, 'skip': skip, 'limit': limit, 'pages': pages},
  };
}

class Data {
  int? id;
  int? position;

  String? enShortName;
  String? enFullName;
  String? arShortName;
  String? arFullName;

  // Additional languages can be added by the API.
  Map<String, dynamic> translations;

  Data({
    this.id,
    this.position,
    this.enShortName,
    this.enFullName,
    this.arShortName,
    this.arFullName,
    this.translations = const {},
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: _toInt(json['id']),
      position: _toInt(json['position']),
      enShortName: json['en_short_name']?.toString(),
      enFullName: json['en_full_name']?.toString(),
      arShortName: json['ar_short_name']?.toString(),
      arFullName: json['ar_full_name']?.toString(),
      translations: Map<String, dynamic>.from(json),
    );
  }

  String shortName(String language) {
    return translations['${language}_short_name']?.toString() ??
        enShortName ??
        arShortName ??
        '';
  }

  String fullName(String language) {
    return translations['${language}_full_name']?.toString() ??
        enFullName ??
        arFullName ??
        '';
  }

  Map<String, dynamic> toJson() => {
    ...translations,
    'id': id,
    'position': position,
    'en_short_name': enShortName,
    'en_full_name': enFullName,
    'ar_short_name': arShortName,
    'ar_full_name': arFullName,
  };
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
