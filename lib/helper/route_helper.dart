import 'package:get/get.dart';
import 'package:nazar_e_alam/view/base/bottom_navbar.dart';
import 'package:nazar_e_alam/view/screens/alphabet/alphabet_wrapper.dart';
import 'package:nazar_e_alam/view/screens/audio/audio_list_wrapper.dart';
import 'package:nazar_e_alam/view/screens/audio/reciters_wrapper.dart';
import 'package:nazar_e_alam/view/screens/chand/chand_wrapper.dart';
import 'package:nazar_e_alam/view/screens/compass/compass_wrapper.dart';
import 'package:nazar_e_alam/view/screens/dhikr/api%20dhikr/dhikr_count_screen.dart';
import 'package:nazar_e_alam/view/screens/dhikr/dhikr_screen_wrapper.dart';
import 'package:nazar_e_alam/view/screens/dhikr/local%20stroge%20dhikr/local_dhikr_add_screen.dart';
import 'package:nazar_e_alam/view/screens/dua/api%20dua/api_dua_view_screen.dart';
import 'package:nazar_e_alam/view/screens/dua/dua_screen_wrapper.dart';
import 'package:nazar_e_alam/view/screens/dua/local%20stroge%20dua/local_dhikr_add_screen.dart';
import 'package:nazar_e_alam/view/screens/hadith/hadith_books_wrapper.dart';
import 'package:nazar_e_alam/view/screens/hadith/hadith_chapters_wrapper.dart';
import 'package:nazar_e_alam/view/screens/hadith/hadith_details_wrapper.dart';
import 'package:nazar_e_alam/view/screens/hadith/hadith_screen_wrapper.dart';
// import 'package:nazar_e_alam/view/screens/haram_ingredients_food/haram_food_detaile_info.dart';
// import 'package:nazar_e_alam/view/screens/haram_ingredients_food/haram_ingredients_food.dart';
import 'package:nazar_e_alam/view/screens/home/home_screen.dart';
import 'package:nazar_e_alam/view/screens/mubarak_names/mubarak_names_wrapper.dart';
// import 'package:nazar_e_alam/view/screens/name_generator/islamic_name_generator_screen.dart';
import 'package:nazar_e_alam/view/screens/nearby_mosque/nearby_mosque_wrapper.dart';
// import 'package:nazar_e_alam/view/screens/payment/donation_type_screen.dart';
// import 'package:nazar_e_alam/view/screens/payment/payment_type_screen.dart';
import 'package:nazar_e_alam/view/screens/prayer_adjustment/prayer_adjustment_wrapper.dart';
import 'package:nazar_e_alam/view/screens/quran/sura_detile_wrapper.dart';
import 'package:nazar_e_alam/view/screens/quran/sura_list_wrapper.dart';
import 'package:nazar_e_alam/view/screens/settings/settings_wrapper.dart';
// import 'package:nazar_e_alam/view/screens/sifat_name/sifat_name_details_wrapper.dart';
// import 'package:nazar_e_alam/view/screens/sifat_name/sifat_name_wrapper.dart';
import 'package:nazar_e_alam/view/screens/splash/splash_screen.dart';
import 'package:nazar_e_alam/view/screens/wallpapers/wallpaper_wrapper.dart';
import 'package:nazar_e_alam/view/screens/zakat/zakat_calculator_wrapper.dart';
import 'package:nazar_e_alam/view/screens/zakat/zakat_detaile_wrapper.dart';
import 'package:nazar_e_alam/view/screens/kalima/kalima_wrapper.dart';
import 'package:nazar_e_alam/view/screens/shijra/shijra_wrapper.dart';
import 'package:nazar_e_alam/view/screens/memorable_days/memorable_days_wrapper.dart';
import 'package:nazar_e_alam/view/screens/fateha/fateha_wrapper.dart';
import 'package:nazar_e_alam/view/screens/wazaif/wazaif_wrapper.dart';
// import 'package:nazar_e_alam/view/screens/mubarak_names/mubarak_names_screen.dart';

// import '../view/screens/payment/donated_list.dart';

class RouteHelper {
  static String initial = "/";
  static String home = "/home";
  static String bottomNavbar = "/bottomNavbar";
  static String dhikr = "/dhikr";
  static String dhikrCount = "/dhikrCount";
  static String addDhikr = "/addDhikr";
  static String compass = "/Compass";
  static String nearByMosque = "/nearByMosque";
  static String dua = "/dua";
  static String duaView = "/duaView";
  // static String sifatName = "/sifatName";
  // static String sifatNameDetaile = "/sifatNameDetaile";
  static String hadithChapters = "/hadithChapters";
  static String allHadith = "/allHadith";
  static String hadithDetails = "/hadithDetails";
  static String hadithBookName = "/hadithBookName";
  static String mubraak = "/mubarak_names";
  // static String haramIngredientsFood = "/haramIngredientsFood";
  // static String haramFoodDetaile = "/haramFoodDetaile";
  static String zakatCalculator = "/zakatCalculator";
  static String zakatDetaile = "/zakatDetaile";
  static String suraList = "/suraList";
  static String suraDetaile = "/suraDetaile";
  static String duaAdd = "/duaAdd";
  static String settings = "/settings";
  // static String userDonatedList = "/userDonatedList";
  // static String donationTypeList = "/donationTypeList";
  // static String paymentType = "/paymentType";
  static String recters = "/recters";
  static String audioList = "/audioList";
  static String wallpaperScreens = "/wallpaperScreens";
  static String alphabetScreens = "/alphabetScreens";
  static String prayerAdjustment = "/prayerAdjustment";
  static String chand = "/chand";
  static String kalima = "/kalima";
  static String shijra = "/shijra";
  static String memorabledays = "/memorabledays";
  static String fateha = "/fateha";
  static String wazaif = "/wazaif";
  // static String aiNameGenerator = "/aiNameGenerator";

  static String getInitialRoute() => initial;
  static String getHomeRoute() => home;
  static String getBottomNavbarRoute() => bottomNavbar;
  static String getDhikrRoute() => dhikr;
  static String getDhikrCountRoute() => dhikrCount;
  static String getAddDhikrRoute() => addDhikr;
  static String getCompassRoute() => compass;
  static String getNearByMosqueRoute() => compass;
  static String getDuaRoute() => dua;
  static String getDuaViewRoute() => duaView;
  // static String getSifatNameRoute() => sifatName;
  // static String getSifatNameDetaileRoute() => sifatNameDetaile;
  static String getHadithChaptersRoute() => hadithChapters;
  static String getAllHadithRoute() => allHadith;
  static String getHadithDetailsRoute() => hadithDetails;
  static String getHadithBookNameRoute() => hadithBookName;
  // static String getHaramIngredientsFoodPageRoute() => haramIngredientsFood;
  // static String getHaramFoodDetailepageRoute() => haramFoodDetaile;
  static String getZakatCalculatorPageRoute() => zakatCalculator;
  static String getZakatDetailePageRoute() => zakatDetaile;
  static String getSuraListPageRoute() => suraList;
  static String getSuraDetailePageRoute() => suraDetaile;
  static String getDuaAddPageRoute() => duaAdd;
  static String getSettingsPageRoute() => settings;
  // static String getDonationListPageRoute(String value) =>
  // "$userDonatedList?value=$value";
  // static String getDonationTypeListPageRoute() => donationTypeList;
  // static String getPaymentTypeListPageRoute() => paymentType;
  static String getRectersPageRoute() => recters;
  static String getAudioListPageRoute() => audioList;
  static String getWallpaperPageRoute() => wallpaperScreens;
  static String getAlphabetPageRoute() => alphabetScreens;
  static String getPrayerAdjustmentPageRoute() => prayerAdjustment;
  static String getChandPageRoute() => chand;
  // static String getAiNameGeneratorPageRoute() => aiNameGenerator;

  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => const SplashScreen(),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: bottomNavbar,
      page: () => const BottomNavbarScreen(),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: dhikr,
      page: () => const DhikrScreenWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: mubraak,
      page: () => const MubarakNamesWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),    
    GetPage(
      name: memorabledays,
      page: () => const MemorableDaysWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: dhikrCount,
      page: () => const DhikrCountScreen(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: addDhikr,
      page: () => LocalDhikrAddScreen(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: compass,
      page: () => const CompassWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: nearByMosque,
      page: () => const NearbyMosqueWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: dua,
      page: () => const DuaScreenWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: duaView,
      page: () => const DuasViewScreen(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: kalima,
      page: () => const KalimaWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: shijra,
      page: () => const ShijraWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),    
    GetPage(
      name: wazaif,
      page: () => const WazaifWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    // GetPage(
    //   name: sifatName,
    //   page: () => const SifatNameWrapper(appBackButton: true),
    //   transition: Transition.cupertinoDialog,
    // ),
    // GetPage(
    //   name: sifatNameDetaile,
    //   page: () => const SifatNameDetailsWrapper(appBackButton: true),
    //   transition: Transition.cupertinoDialog,
    // ),
    GetPage(
      name: hadithChapters,
      page: () => const HadithChaptersWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: allHadith,
      page: () => const HadithScreenWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: hadithDetails,
      page: () => const HadithDetailsWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: hadithBookName,
      page: () => const HadithBooksWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),    
    GetPage(
      name: fateha,
      page: () => const FatehaWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    // GetPage(
    //   name: haramIngredientsFood,
    //   page: () => const HaramIngredientsFood(appBackButton: true),
    //   transition: Transition.cupertinoDialog,
    // ),
    // GetPage(
    //   name: haramFoodDetaile,
    //   page: () => const HaramFoodDetaileInfoScreen(appBackButton: true),
    //   transition: Transition.cupertinoDialog,
    // ),
    GetPage(
      name: zakatCalculator,
      page: () => const ZakatCalculatorWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: zakatDetaile,
      page: () => const ZakatDetaileWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: suraList,
      page: () => const SuraListWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: suraDetaile,
      page: () => const SuraDetileWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: duaAdd,
      page: () => LocalDuaAddScreen(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    // GetPage(
    //   name: userDonatedList,
    //   page: () => UserDonateScreen(
    //     appBackButton: true,
    //     value: Get.parameters['value'] ?? '1',
    //   ),
    //   transition: Transition.cupertinoDialog,
    // ),
    // GetPage(
    //   name: donationTypeList,
    //   page: () => const DonationTypeScreen(appBackButton: true),
    //   transition: Transition.cupertinoDialog,
    // ),
    // GetPage(
    //   name: paymentType,
    //   page: () => PaymentTypeScreen(appBackButton: true),
    //   transition: Transition.cupertinoDialog,
    // ),
    GetPage(
      name: recters,
      page: () => const RecitersWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: audioList,
      page: () => const AudioListWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: wallpaperScreens,
      page: () => const WallpaperWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: alphabetScreens,
      page: () => const AlphabetWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: prayerAdjustment,
      page: () => const PrayerAdjustmentWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    GetPage(
      name: chand,
      page: () => const ChandWrapper(appBackButton: true),
      transition: Transition.cupertinoDialog,
    ),
    // GetPage(
    //   name: aiNameGenerator,
    //   page: () => IslamicNameGeneratorScreen(appBackButton: true),
    //   transition: Transition.cupertinoDialog,
    // ),
  ];
}
