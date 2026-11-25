class ReciterSurahsModel {
  ReciterInfo? reciter;
  String? host;
  List<Surah>? surahs;

  ReciterSurahsModel({this.reciter, this.host, this.surahs});

  ReciterSurahsModel.fromJson(Map<String, dynamic> json) {
    reciter = json['reciter'] != null
        ? ReciterInfo.fromJson(json['reciter'])
        : null;

    host = json['host'];

    if (json['surahs'] != null) {
      surahs = <Surah>[];
      for (final item in json['surahs']) {
        surahs!.add(Surah.fromJson(item));
      }
    }
  }
}

class ReciterInfo {
  int? id;
  String? slug;
  String? name;
  String? bitrate;
  String? profilePicture;

  ReciterInfo({
    this.id,
    this.slug,
    this.name,
    this.bitrate,
    this.profilePicture,
  });

  ReciterInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    bitrate = json['bitrate']?.toString();
    profilePicture = json['profile_picture'];
  }
}

class Surah {
  int? number;
  String? arabicName;
  int? versesCount;
  String? revelationPlace;

  Surah({this.number, this.arabicName, this.versesCount, this.revelationPlace});

  Surah.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    arabicName = json['arabic_name'];
    versesCount = json['verses_count'];
    revelationPlace = json['revelation_place'];
  }
}
