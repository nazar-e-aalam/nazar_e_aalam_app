// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/dhikr/dhikr_screen.dart';
import 'package:nazar_e_alam/view/screens/dhikr/modern/modern_dhikr_screen.dart';

/// Routes to the classic or modern Dhikr screen based on the saved layout
/// preference. Classic = existing tab + Card layout; Modern = glass tabs +
/// animated rank-chipped list.
class DhikrScreenWrapper extends StatefulWidget {
  final bool appBackButton;
  const DhikrScreenWrapper({super.key, required this.appBackButton});

  @override
  State<DhikrScreenWrapper> createState() => _DhikrScreenWrapperState();
}

class _DhikrScreenWrapperState extends State<DhikrScreenWrapper> {
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
            ? ModernDhikrScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : DhikrScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
