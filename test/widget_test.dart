// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'package:nazar_e_alam/main.dart';
import 'package:nazar_e_alam/helper/get_di.dart' as di;
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/helper/theme_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Map<String, String>> languages;
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (call) async {
        switch (call.method) {
          case 'read':
            return null;

          case 'write':
          case 'delete':
          case 'deleteAll':
            return null;

          case 'readAll':
            return <String, String>{};

          case 'containsKey':
            return false;

          default:
            throw MissingPluginException(
              'Unmocked secure storage method: ${call.method}',
            );
        }
      });
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late Directory testDirectory;

  setUpAll(() async {
    testDirectory = await Directory.systemTemp.createTemp(
      'nazar_e_alam_widget_test_',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getApplicationDocumentsDirectory':
            case 'getApplicationSupportDirectory':
            case 'getTemporaryDirectory':
            case 'getApplicationCacheDirectory':
              return testDirectory.path;

            default:
              throw MissingPluginException(
                'Unmocked path_provider method: ${call.method}',
              );
          }
        });

    SharedPreferences.setMockInitialValues({});

    debugPrint('STEP 1: Starting dependency initialization');

    final prefs = await SharedPreferences.getInstance();

    debugPrint('STEP 2: SharedPreferences initialized');

    languages = await di.init(prefs);

    debugPrint('STEP 3: Dependencies initialized');
  });
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    debugPrint('STEP 1: Starting dependency initialization');

    final prefs = await SharedPreferences.getInstance();

    debugPrint('STEP 2: SharedPreferences initialized');

    languages = await di.init(prefs);

    debugPrint('STEP 3: Dependencies initialized');
  });

  tearDownAll(() {
    Get.reset();
  });

  testWidgets('App starts successfully', (tester) async {
    final layoutController = Get.find<HomeLayoutController>();

    final currentLayout = layoutController.currentLayout.value;

    final lightTheme = getAppTheme(currentLayout, false);
    final darkTheme = getAppTheme(currentLayout, true);

    await tester.pumpWidget(
      MyApp(languages: languages, lightTheme: lightTheme, darkTheme: darkTheme),
    );

    debugPrint('STEP 4: App widget built');

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(GetMaterialApp), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    debugPrint('STEP 5: Splash timer processed');

    expect(find.byType(MyApp), findsOneWidget);

    // Dispose the widget tree before resetting GetX.
    await tester.pumpWidget(const SizedBox.shrink());

    debugPrint('STEP 6: Test completed successfully');
  });
}
