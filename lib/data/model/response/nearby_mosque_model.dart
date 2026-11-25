class NearbyMosqueModel {
  final String? source;
  final int count;
  final List<MosqueModel> mosques;

  const NearbyMosqueModel({
    this.source,
    required this.count,
    required this.mosques,
  });

  factory NearbyMosqueModel.fromJson(Map<String, dynamic> json) {
    final results = json['mosques'];

    if (results is! List) {
      throw const FormatException('Invalid mosque response');
    }

    final mosques = results
        .whereType<Map>()
        .map((item) => MosqueModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return NearbyMosqueModel(
      source: json['source'] as String?,
      count: (json['count'] as num?)?.toInt() ?? mosques.length,
      mosques: mosques,
    );
  }
}

class MosqueModel {
  final String name;
  final String? address;
  final double? lat;
  final double? lon;
  final double? distanceKm;
  final String? source;
  final String? googleMapsUrl;

  const MosqueModel({
    required this.name,
    this.address,
    this.lat,
    this.lon,
    this.distanceKm,
    this.source,
    this.googleMapsUrl,
  });

  factory MosqueModel.fromJson(Map<String, dynamic> json) {
    return MosqueModel(
      name: json['name'] as String? ?? '--',
      address: json['address'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      source: json['source'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
    );
  }

  bool get hasValidCoordinates {
    final latitude = lat;
    final longitude = lon;

    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  MosqueModel copyWith({double? distanceKm}) {
    return MosqueModel(
      name: name,
      address: address,
      lat: lat,
      lon: lon,
      distanceKm: distanceKm ?? this.distanceKm,
      source: source,
      googleMapsUrl: googleMapsUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'lat': lat,
      'lon': lon,
      'distance_km': distanceKm,
      'source': source,
      'google_maps_url': googleMapsUrl,
    };
  }
}
