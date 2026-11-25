// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/audio/modern/modern_reciters_screen.dart';
import 'package:nazar_e_alam/view/screens/audio/reciters_screen.dart';

/// Routes to the classic or modern Reciters screen based on the saved
/// layout preference.
class RecitersWrapper extends StatefulWidget {
  final bool? appBackButton;
  const RecitersWrapper({super.key, this.appBackButton});

  @override
  State<RecitersWrapper> createState() => _RecitersWrapperState();
}

class _RecitersWrapperState extends State<RecitersWrapper> {
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
            ? ModernRecitersScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : ReciterScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
