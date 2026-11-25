class DuaListModel {
  List<Data>? data;
  int? total;
  int? skip;
  int? limit;
  int? pages;

  DuaListModel({this.data, this.total, this.skip, this.limit, this.pages});

  DuaListModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] ?? json['data'];

    if (items is List) {
      data = items
          .map((item) => Data.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else {
      data = [];
    }

    final meta = json['meta'];

    if (meta is Map) {
      total = meta['total'];
      skip = meta['skip'];
      limit = meta['limit'];
      pages = meta['pages'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'items': data?.map((item) => item.toJson()).toList() ?? [],
      'meta': {'total': total, 'skip': skip, 'limit': limit, 'pages': pages},
    };
  }
}

class Data {
  int? id;
  int? position;

  String? enShortName;
  String? enFullName;
  String? arShortName;
  String? arFullName;

  Data({
    this.id,
    this.position,
    this.enShortName,
    this.enFullName,
    this.arShortName,
    this.arFullName,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    position = json['position'];

    enShortName = json['en_short_name'];
    enFullName = json['en_full_name'];

    arShortName = json['ar_short_name'];
    arFullName = json['ar_full_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'en_short_name': enShortName,
      'en_full_name': enFullName,
      'ar_short_name': arShortName,
      'ar_full_name': arFullName,
    };
  }
}
