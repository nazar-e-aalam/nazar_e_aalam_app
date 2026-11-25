// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';

import 'memorable_days_screen.dart';
import 'modern/modern_memorable_days_screen.dart';

class MemorableDaysWrapper extends StatelessWidget {
  final bool appBackButton;

  const MemorableDaysWrapper({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final modern =
          Get.find<HomeLayoutController>().currentLayout.value ==
          HomeLayoutController.modern;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: modern
            ? ModernMemorableDaysScreen(
                key: const ValueKey('modern'),
                appBackButton: appBackButton,
              )
            : MemorableDaysScreen(
                key: const ValueKey('classic'),
                appBackButton: appBackButton,
              ),
      );
    });
  }
}
