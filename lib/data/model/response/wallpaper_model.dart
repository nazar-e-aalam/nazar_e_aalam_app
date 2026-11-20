
class WallpaperModel {
  List<Wallpapers> data;
  int total;
  int skip;
  int limit;
  int pages;

  WallpaperModel({
    this.data = const [],
    this.total = 0,
    this.skip = 0,
    this.limit = 50,
    this.pages = 0,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    final meta = json['meta'] as Map? ?? {};

    return WallpaperModel(
      data: items
          .map(
            (item) => Wallpapers.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      total: (meta['total'] as num?)?.toInt() ?? items.length,
      skip: (meta['skip'] as num?)?.toInt() ?? 0,
      limit: (meta['limit'] as num?)?.toInt() ?? 50,
      pages: (meta['pages'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': data.map((item) => item.toJson()).toList(),
        'meta': {
          'total': total,
          'skip': skip,
          'limit': limit,
          'pages': pages,
        },
      };
}

class Wallpapers {
  int? id;
  String? name;
  String? image;

  Wallpapers({
    this.id,
    this.name,
    this.image,
  });

  // Compatibility with older UI references.
  String? get wallpaper => image;

  factory Wallpapers.fromJson(Map<String, dynamic> json) {
    return Wallpapers(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
      };
}
