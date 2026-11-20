class CityesModel {
  List<String>? data;

  CityesModel({this.data});

  CityesModel.fromJson(List<dynamic> json) {
    data = json.map((city) => city['name'].toString()).toList();
  }

  Map<String, dynamic> toJson() {
    return {'data': data};
  }
}
