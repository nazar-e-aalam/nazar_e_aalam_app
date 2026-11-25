// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/hadith/all_hadith_screen.dart';
import 'package:nazar_e_alam/view/screens/hadith/modern/modern_all_hadith_screen.dart';

/// Routes to the classic or modern All Hadith screen based on the saved
/// layout preference (HomeLayoutController). Classic = existing generic Card
/// layout; Modern = glass + animated rank-chipped list.
class HadithScreenWrapper extends StatefulWidget {
  final bool appBackButton;
  const HadithScreenWrapper({super.key, required this.appBackButton});

  @override
  State<HadithScreenWrapper> createState() => _HadithScreenWrapperState();
}

class _HadithScreenWrapperState extends State<HadithScreenWrapper> {
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
            ? ModernAllHadithScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : AllHadithScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
