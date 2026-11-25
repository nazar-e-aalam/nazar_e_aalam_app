// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/dua/dua_screen.dart';
import 'package:nazar_e_alam/view/screens/dua/modern/modern_dua_screen.dart';

/// Routes to the classic or modern Dua screen based on the saved layout
/// preference. Classic = existing tab + Card layout; Modern = glass tabs +
/// animated rank-chipped list.
class DuaScreenWrapper extends StatefulWidget {
  final bool appBackButton;
  const DuaScreenWrapper({super.key, required this.appBackButton});

  @override
  State<DuaScreenWrapper> createState() => _DuaScreenWrapperState();
}

class _DuaScreenWrapperState extends State<DuaScreenWrapper> {
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
            ? ModernDuaScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : DuaScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
