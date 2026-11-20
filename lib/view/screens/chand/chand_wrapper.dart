// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/chand/chand_screen.dart';
import 'package:nazar_e_alam/view/screens/chand/modern/modern_chand_screen.dart';

/// Routes to the classic or modern Chand screen based on the saved layout
/// preference. Classic = simple Card layout; Modern = glassmorphism +
/// animated moon phase.
class ChandWrapper extends StatefulWidget {
  final bool appBackButton;
  const ChandWrapper({super.key, required this.appBackButton});

  @override
  State<ChandWrapper> createState() => _ChandWrapperState();
}

class _ChandWrapperState extends State<ChandWrapper> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final modern = Get.find<HomeLayoutController>().currentLayout.value == HomeLayoutController.modern;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: modern
            ? ModernChandScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : ChandScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
