// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'settings_screen.dart';
import 'modern/modern_settings_screen.dart';

class SettingsWrapper extends StatelessWidget {
  final bool appBackButton;
  const SettingsWrapper({super.key, required this.appBackButton});
  @override
  Widget build(BuildContext context) => Obx(() {
    final modern =
        Get.find<HomeLayoutController>().currentLayout.value ==
        HomeLayoutController.modern;
    return modern
        ? ModernSettingsScreen(appBackButton: appBackButton)
        : SettingsScreen(appBackButton: appBackButton);
  });
}
