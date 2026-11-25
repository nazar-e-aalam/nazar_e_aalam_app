// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/hadith/hadith_chapters_screen.dart';
import 'package:nazar_e_alam/view/screens/hadith/modern/modern_hadith_chapters_screen.dart';

/// Routes to the classic or modern Hadith Chapters screen based on the saved
/// layout preference.
class HadithChaptersWrapper extends StatefulWidget {
  final bool appBackButton;
  const HadithChaptersWrapper({super.key, required this.appBackButton});

  @override
  State<HadithChaptersWrapper> createState() => _HadithChaptersWrapperState();
}

class _HadithChaptersWrapperState extends State<HadithChaptersWrapper> {
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
            ? ModernHadithChaptersScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : HadithChaptersScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
