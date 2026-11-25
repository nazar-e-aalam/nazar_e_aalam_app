// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_qiblah_advanced/flutter_qiblah_advanced.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'package:nazar_e_alam/view/screens/compass/widget/qiblah_compass.dart';

/// Modern Compass screen — glass surface.
class ModernCompassScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernCompassScreen({super.key, required this.appBackButton});

  @override
  State<ModernCompassScreen> createState() => _ModernCompassScreenState();
}

class _ModernCompassScreenState extends State<ModernCompassScreen> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'qibla_compass'.tr,
        isBackButtonExist: widget.appBackButton == true ? true : false,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _deviceSupport,
          builder: (_, AsyncSnapshot<bool?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const QuiblaeShimmerScreen();
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("error: ${snapshot.error.toString()}".tr),
              );
            }

            if (snapshot.data!) {
              return ModernGlassPanel(
                color: dark
                    ? const Color(0x0AFFFFFF)
                    : AppColorModern.glassFill,
                child: const QiblahCompassWidget(),
              );
            }
            return Center(
              child: Text('our_compass_not_support_in_your_device'.tr),
            );
          },
        ),
      ),
    );
  }
}
