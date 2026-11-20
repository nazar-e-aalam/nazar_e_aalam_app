// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';

import 'shijra_screen.dart';
import 'modern/modern_shijra_screen.dart';

class ShijraWrapper extends StatelessWidget {
  final bool appBackButton;

  const ShijraWrapper({
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
            ? ModernShijraScreen(
                key: const ValueKey('modern'),
                appBackButton: appBackButton,
              )
            : ShijraScreen(
                key: const ValueKey('classic'),
                appBackButton: appBackButton,
              ),
      );
    });
  }
}
