class DikirDetailsModel {
  bool? status;
  String? message;
  Data? data;

  DikirDetailsModel({this.status, this.message, this.data});

  factory DikirDetailsModel.fromJson(Map<String, dynamic> json) {
    final details = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : json;

    return DikirDetailsModel(
      status: json['status'] ?? true,
      message: json['message'],
      data: Data.fromJson(details),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class Data {
  int? id;
  int? position;

  String? arShortName;
  String? arFullName;
  String? enShortName;
  String? enFullName;

  Map<String, dynamic> translations;

  Data({
    this.id,
    this.position,
    this.arShortName,
    this.arFullName,
    this.enShortName,
    this.enFullName,
    this.translations = const {},
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: _toInt(json['id']),
      position: _toInt(json['position']),
      arShortName: json['ar_short_name']?.toString(),
      arFullName: json['ar_full_name']?.toString(),
      enShortName: json['en_short_name']?.toString(),
      enFullName: json['en_full_name']?.toString(),
      translations: Map<String, dynamic>.from(json),
    );
  }

  String shortName(String language) =>
      translations['${language}_short_name']?.toString() ??
      enShortName ??
      arShortName ??
      '';

  String fullName(String language) =>
      translations['${language}_full_name']?.toString() ??
      enFullName ??
      arFullName ??
      '';

  Map<String, dynamic> toJson() => {
    ...translations,
    'id': id,
    'position': position,
    'ar_short_name': arShortName,
    'ar_full_name': arFullName,
    'en_short_name': enShortName,
    'en_full_name': enFullName,
  };
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
