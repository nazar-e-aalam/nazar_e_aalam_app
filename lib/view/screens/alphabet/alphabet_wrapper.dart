// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/alphabet/alphabet_screen.dart';
import 'package:nazar_e_alam/view/screens/alphabet/modern/modern_alphabet_screen.dart';

/// Routes to the classic or modern Alphabet screen based on the saved
/// layout preference.
class AlphabetWrapper extends StatefulWidget {
  final bool? appBackButton;
  const AlphabetWrapper({super.key, this.appBackButton});

  @override
  State<AlphabetWrapper> createState() => _AlphabetWrapperState();
}

class _AlphabetWrapperState extends State<AlphabetWrapper> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final layout = Get.find<HomeLayoutController>().currentLayout.value;
      final modern = layout == HomeLayoutController.modern;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: modern
            ? ModernAlphabetScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : AlphabetScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
