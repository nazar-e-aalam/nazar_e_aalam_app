// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';

import 'mubarak_names_screen.dart';
import 'modern/modern_mubarak_names_screen.dart';

class MubarakNamesWrapper extends StatelessWidget {
  final bool appBackButton;

  const MubarakNamesWrapper({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final modern =
          Get.find<HomeLayoutController>().currentLayout.value ==
          HomeLayoutController.modern;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: modern
            ? ModernMubarakNamesScreen(
                key: const ValueKey('modern'),
                appBackButton: appBackButton,
              )
            : MubarakNamesScreen(
                key: const ValueKey('classic'),
                appBackButton: appBackButton,
              ),
      );
    });
  }
}
