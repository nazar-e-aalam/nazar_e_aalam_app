// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/zakat/modern/modern_zakat_calculator_screen.dart';
import 'package:nazar_e_alam/view/screens/zakat/zakat_calculator.dart';

/// Routes to the classic or modern Zakat Calculator screen based on the saved
/// layout preference.
class ZakatCalculatorWrapper extends StatefulWidget {
  final bool appBackButton;
  const ZakatCalculatorWrapper({super.key, required this.appBackButton});

  @override
  State<ZakatCalculatorWrapper> createState() => _ZakatCalculatorWrapperState();
}

class _ZakatCalculatorWrapperState extends State<ZakatCalculatorWrapper> {
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
            ? ModernZakatCalculatorScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : ZakatCalculator(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
