// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/splash_controller.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // We wait for the first frame to be drawn on the screen BEFORE starting the timer.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Now the splash is visible. Start the 600ms timer.
      final timerFuture = Future<void>.delayed(const Duration(milliseconds: 600));

      // 2. Kick off background work
      Get.find<PrayerTimeController>().getLocation();

      // 3. Precache logo
      try {
        await precacheImage(const AssetImage(Images.APP_LOGO), context);
      } catch (_) {}

      // 4. Wait for timer
      await timerFuture;
      if (!mounted) return;

      // 5. Navigate
      Get.find<SplashController>().navigator();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Images.APP_LOGO,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Text(
              AppConstants.APP_NAME,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}