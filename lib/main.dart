// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';
import 'package:nazar_e_alam/controller/theme_controller.dart';
import 'package:nazar_e_alam/helper/theme_helper.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/view/screens/splash/splash_screen.dart';

import 'controller/internet_check_controller.dart';
import 'controller/prayer_time_controller.dart';
import 'helper/audio_service_helper.dart';
import 'helper/get_di.dart' as di;
import 'helper/route_helper.dart';
import 'util/messages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    FlutterDisplayMode.setHighRefreshRate().catchError((_) => <DisplayMode>[]);
  }

  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  _BootConfig? _config;

  bool _animationCompleted = false;

  Object? _bootError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(_initialize());
    });
  }

  // ==================== INITIALIZATION ====================

  Future<void> _initialize() async {
    try {
      final config = await _boot();

      if (!mounted) return;

      setState(() {
        _config = config;
      });
    } catch (e, stackTrace) {
      debugPrint('Application initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _bootError = e;
      });
    }
  }

  Future<_BootConfig> _boot() async {
    final stopwatch = Stopwatch()..start();

    // 1. Audio Service (Background)
    unawaited(
      AudioServiceHelper.init().catchError((Object e, StackTrace st) {
        debugPrint('Audio initialization error: $e');
      }),
    );

    // 2. SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // 3. Dependency Injection
    await di.init(prefs);

    // 4. Internet Controller
    if (!Get.isRegistered<InternetController>()) {
      Get.put(InternetController());
    }

    // 5. Location (Background)
    unawaited(
      Get.find<PrayerTimeController>().getLocation().catchError((
        Object e,
        StackTrace st,
      ) {
        debugPrint('Location initialization error: $e');
      }),
    );

    // 6. Load Languages
    final languages = await di.loadLanguagesFast();

    // 7. Prepare Themes
    final layout = Get.find<HomeLayoutController>().currentLayout.value;

    final light = getAppTheme(layout, false);
    final dark = getAppTheme(layout, true);

    stopwatch.stop();

    debugPrint(
      'Bootstrap completed in '
      '${stopwatch.elapsedMilliseconds} ms',
    );

    return _BootConfig(languages: languages, light: light, dark: dark);
  }

  // ==================== ANIMATION CALLBACK ====================

  void _onAnimationCompleted() {
    if (!mounted || _animationCompleted) return;

    setState(() {
      _animationCompleted = true;
    });

    debugPrint('Splash pixel animation completed');
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final config = _config;

    // Initialization and animation must both complete.
    if (config != null && _animationCompleted) {
      return MyApp(
        languages: config.languages,
        lightTheme: config.light,
        darkTheme: config.dark,
      );
    }

    // Display an error instead of remaining stuck forever.
    if (_bootError != null) {
      return _buildErrorScreen();
    }

    // Keep the same splash widget mounted throughout boot.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        key: const ValueKey('bootstrap_pixel_splash'),
        onCompleted: _onAnimationCompleted,
      ),
    );
  }

  // ==================== ERROR SCREEN ====================

  Widget _buildErrorScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to initialize application',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please close and reopen the application.',
                    textAlign: TextAlign.center,
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    Text(
                      _bootError.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BootConfig {
  final Map<String, Map<String, String>> languages;
  final ThemeData light;
  final ThemeData dark;
  _BootConfig({
    required this.languages,
    required this.light,
    required this.dark,
  });
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const MyApp({
    super.key,
    required this.languages,
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetBuilder<LocalizationController>(
      builder: (loc) {
        final activeLanguages = loc.allLanguages.isNotEmpty
            ? loc.allLanguages
            : languages;

        return GetMaterialApp(
          title: AppConstants.APP_NAME,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          themeMode: themeController.darkTheme
              ? ThemeMode.dark
              : ThemeMode.light, // ignore: argument_type_not_assignable
          locale: loc.locale,
          initialRoute: RouteHelper.bottomNavbar,
          getPages: RouteHelper.routes,
          defaultTransition: Transition.topLevel,
          translations: Messages(languages: activeLanguages),
          fallbackLocale: Locale(
            AppConstants.languages[0].languageCode!,
            AppConstants.languages[0].countryCode!,
          ),
          transitionDuration: const Duration(milliseconds: 300),
          builder: (context, child) {
            final layout = Get.find<HomeLayoutController>().currentLayout.value;
            final activeTheme = themeController.darkTheme
                ? getAppTheme(layout, true)
                : getAppTheme(layout, false);

            return Theme(
              data: activeTheme,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarIconBrightness: Brightness.light,
                ),
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => SafeArea(
                        top: false,
                        bottom: !kIsWeb && Platform.isAndroid,
                        child: child!,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
