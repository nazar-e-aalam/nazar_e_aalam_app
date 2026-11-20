// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/settings/modern/modern_settings_screen.dart';
import 'package:nazar_e_alam/view/screens/settings/settings_screen.dart';

/// Routes to the classic or modern Settings screen based on the saved
/// layout preference.
class SettingsWrapper extends StatefulWidget {
  final bool appBackButton;
  const SettingsWrapper({super.key, required this.appBackButton});

  @override
  State<SettingsWrapper> createState() => _SettingsWrapperState();
}

class _SettingsWrapperState extends State<SettingsWrapper> {
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
            ? ModernSettingsScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : SettingsScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
