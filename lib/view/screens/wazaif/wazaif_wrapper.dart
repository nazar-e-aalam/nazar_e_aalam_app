// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';

import 'wazaif_classic.dart';
import 'modern/wazaif_modern.dart';

/// Routes to the Classic or Modern Wazaif screen
/// based on the saved layout preference.
class WazaifWrapper extends StatefulWidget {
  final bool? appBackButton;

  const WazaifWrapper({super.key, this.appBackButton});

  @override
  State<WazaifWrapper> createState() => _WazaifWrapperState();
}

class _WazaifWrapperState extends State<WazaifWrapper> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final layout = Get.find<HomeLayoutController>().currentLayout.value;

      final modern = layout == HomeLayoutController.modern;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: modern
            ? const WazaifModernScreen(key: ValueKey('modern'))
            : const WazaifClassicScreen(key: ValueKey('classic')),
      );
    });
  }
}
