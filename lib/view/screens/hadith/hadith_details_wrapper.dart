// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/hadith/hadith_details_screen.dart';
import 'package:nazar_e_alam/view/screens/hadith/modern/modern_hadith_details_screen.dart';

/// Routes to the classic or modern Hadith Details screen based on the saved
/// layout preference.
class HadithDetailsWrapper extends StatefulWidget {
  final bool appBackButton;
  const HadithDetailsWrapper({super.key, required this.appBackButton});

  @override
  State<HadithDetailsWrapper> createState() => _HadithDetailsWrapperState();
}

class _HadithDetailsWrapperState extends State<HadithDetailsWrapper> {
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
            ? ModernHadithDetailsScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : HadithDetailsScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
