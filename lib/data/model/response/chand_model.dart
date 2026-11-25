class ChandModel {
  String? city;
  String? gregorianDate;
  int? hijriYear;
  int? hijriMonth;
  int? hijriDay;
  String? hijriMonthName;
  String? source;
  bool? isTentative;
  String? message;

  ChandModel({
    this.city,
    this.gregorianDate,
    this.hijriYear,
    this.hijriMonth,
    this.hijriDay,
    this.hijriMonthName,
    this.source,
    this.isTentative,
    this.message,
  });

  ChandModel.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    gregorianDate = json['gregorian_date'];
    hijriYear = json['hijri_year'];
    hijriMonth = json['hijri_month'];
    hijriDay = json['hijri_day'];
    hijriMonthName = json['hijri_month_name'];
    source = json['source'];
    isTentative = json['is_tentative'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'gregorian_date': gregorianDate,
      'hijri_year': hijriYear,
      'hijri_month': hijriMonth,
      'hijri_day': hijriDay,
      'hijri_month_name': hijriMonthName,
      'source': source,
      'is_tentative': isTentative,
      'message': message,
    };
  }
}
