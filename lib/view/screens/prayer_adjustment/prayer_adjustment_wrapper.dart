// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/prayer_adjustment/modern/modern_prayer_adjustment_screen.dart';
import 'package:nazar_e_alam/view/screens/prayer_adjustment/prayer_adjustment_screen.dart';

/// Routes to the classic or modern Prayer Adjustment screen based on the saved
/// layout preference.
class PrayerAdjustmentWrapper extends StatefulWidget {
  final bool appBackButton;
  const PrayerAdjustmentWrapper({super.key, required this.appBackButton});

  @override
  State<PrayerAdjustmentWrapper> createState() => _PrayerAdjustmentWrapperState();
}

class _PrayerAdjustmentWrapperState extends State<PrayerAdjustmentWrapper> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final layout = Get.find<HomeLayoutController>().currentLayout.value;
      final modern = layout == HomeLayoutController.modern;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: modern
            ? ModernPrayerAdjustmentScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : PrayerAdjustmentScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
