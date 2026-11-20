// ignore_for_file: constant_identifier_name, constant_identifier_names
// import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:nazar_e_alam/data/model/response/language_model.dart';
import 'package:nazar_e_alam/util/images.dart';


class Endpoints {
  static const String DEVICE_REGISTER = 'auth/device/register';
  static const String REFRESH_TOKEN = 'auth/refresh';
  static const String PRAYER_CITIES = 'prayer-times/cities';
  static const String TODAYS_PRAYER_TIME = 'prayer-times/for-location';
  static const String PRAYER_SEEDER = 'prayer-times/auto-seed';
  static const String HIJRI = 'hijri/now';
  static const String HIJRI_FORCE_REFESH = 'hijri/refresh';
  static const String MOSQUE_NEARBY = 'mosques/nearby';
  static const String GET_LOCATION = 'location/get';
  static const String SURAH_LIST = 'chapters';
  static const String DHIKRS = 'dhikrs';
  static const String DUAS = 'duas';
  static const String WALLPAPERS = 'wallpapers';
  static const String SIFAT_NAMES = 'sifat-names';
  static const String RECITERS = 'reciters';
  static const String AUDIO_SURHAS = 'reciters/{slug}/surahs';
  static const String NEARBY_MOSQUE_URL = 'mosques/nearby';
}


class AppConstants {
  // Flutter SDK Version  3.44.0
  static const String APP_NAME = 'Nazar e Aalam';
  // static const String APP_VERSION = "7.0";

  // main base url
  // static const String BASE_URL = "https://zer0spectrum.dpdns.org";
  // static const String BASE_URL = "https://zabi.theme29.com";
  static const String API_BASE_URL = 'https://nazareaalam.dpdns.org/';

  // API's and API Kay's
  static const String HADITH_BASE_URL = 'https://www.hadithapi.com/public';
  static const String NEARBY_MOSQUE_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch';

  //others key

  // Shared Key
  static const String THEME = 'theme';
  static const String isPrayerTme = 'isPrayerTme';
  static const String saveCityName = 'saveCityName';
  static const String notificationSettingsKey = 'prayer_notification_settings';
  static const String HOME_LAYOUT_OVERRIDE_KEY = 'home_layout_override';
  static const String QURAN_MILESTONE_GOAL_KEY = 'quran_milestone_daily_goal';
  static const String QURAN_MILESTONE_PROGRESS_KEY = 'quran_milestone_progress';
  static const String TodaysPrayerTimeModel = 'today_time_prayer';

  // Language Key
  static const String LANGUAGE_CODE = 'language_code';
  static const String COUNTRY_CODE = 'country_code';

  // Islamic Name
  // static const String FAVORITE_KEY = 'islamic_name_favorites';

  // All Language model list section
  static List<LanguageModel> languages = [
    LanguageModel(
      imageUrl: Images.englishIcon,
      languageName: 'English',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.indiaIcon,
      languageName: 'Hindi',
      countryCode: 'IN',
      languageCode: 'hi',
    ),
    LanguageModel(
      imageUrl: Images.indiaIcon,
      languageName: 'Gujarati',
      countryCode: 'IN',
      languageCode: 'guj',
    ),
    LanguageModel(
      imageUrl: Images.arabicIcon,
      languageName: 'Arabic',
      countryCode: 'SA',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: Images.kenyaIcon,
      languageName: 'Swahili',
      countryCode: 'KE',
      languageCode: 'sw',
    ),
    LanguageModel(
      imageUrl: Images.pakistanIcon,
      languageName: 'Urdu',
      countryCode: 'PK',
      languageCode: 'ur',
    ),
  ];
}
