class DuaDetailsModel {
  Data? data;

  DuaDetailsModel({this.data});

  DuaDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json;

    if (rawData is Map && rawData['id'] != null) {
      data = Data.fromJson(Map<String, dynamic>.from(rawData));
    }
  }

  Map<String, dynamic> toJson() {
    return {'data': data?.toJson()};
  }
}

class Data {
  int? id;
  int? position;

  String? arShortName;
  String? arFullName;
  String? enShortName;
  String? enFullName;

  Data({
    this.id,
    this.position,
    this.arShortName,
    this.arFullName,
    this.enShortName,
    this.enFullName,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    position = json['position'];

    arShortName = json['ar_short_name'];
    arFullName = json['ar_full_name'];

    enShortName = json['en_short_name'];
    enFullName = json['en_full_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'ar_short_name': arShortName,
      'ar_full_name': arFullName,
      'en_short_name': enShortName,
      'en_full_name': enFullName,
    };
  }
}
