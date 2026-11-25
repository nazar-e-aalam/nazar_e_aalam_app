// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/compass/compass_screen.dart';
import 'package:nazar_e_alam/view/screens/compass/modern/modern_compass_screen.dart';

/// Routes to the classic or modern Compass screen based on the saved
/// layout preference.
class CompassWrapper extends StatefulWidget {
  final bool appBackButton;
  const CompassWrapper({super.key, required this.appBackButton});

  @override
  State<CompassWrapper> createState() => _CompassWrapperState();
}

class _CompassWrapperState extends State<CompassWrapper> {
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
            ? ModernCompassScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : CompassScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
