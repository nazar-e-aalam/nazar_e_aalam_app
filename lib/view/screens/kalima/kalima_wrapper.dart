// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';

import 'kalima_screen.dart';
import 'modern/modern_kalima_screen.dart';

/// Switches between Classic and Modern Kalima Sharif screens
/// according to the user's saved home layout preference.
class KalimaWrapper extends StatelessWidget {
  final bool appBackButton;

  const KalimaWrapper({
    super.key,
    required this.appBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final modern =
          Get.find<HomeLayoutController>().currentLayout.value ==
              HomeLayoutController.modern;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(
              opacity: animation,
              child: child,
            ),
        child: modern
            ? ModernKalimaScreen(
                key: const ValueKey('modern'),
                appBackButton: appBackButton,
              )
            : KalimaScreen(
                key: const ValueKey('classic'),
                appBackButton: appBackButton,
              ),
      );
    });
  }
}
