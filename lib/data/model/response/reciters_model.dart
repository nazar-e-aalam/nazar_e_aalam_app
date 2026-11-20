
class RecitersModel {
  bool? result;
  List<Data>? data;

  RecitersModel({this.result, this.data});

  RecitersModel.fromJson(Map<String, dynamic> json) {
    result = json['result'];

    if (json['items'] != null) {
      data = <Data>[];
      for (final item in json['items']) {
        data!.add(Data.fromJson(item));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};

    jsonData['result'] = result;
    jsonData['items'] = data?.map((v) => v.toJson()).toList();

    return jsonData;
  }
}

class Data {
  int? id;
  String? name;
  String? slug;
  String? bitrate;
  String? profilePicture;

  Data({
    this.id,
    this.name,
    this.slug,
    this.bitrate,
    this.profilePicture,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    bitrate = json['bitrate']?.toString();
    profilePicture = json['profile_picture'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'bitrate': bitrate,
      'profile_picture': profilePicture,
    };
  }
}
