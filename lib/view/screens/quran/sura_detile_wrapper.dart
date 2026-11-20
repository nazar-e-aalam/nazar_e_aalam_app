// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/quran/modern/modern_sura_detile_screen.dart';
import 'package:nazar_e_alam/view/screens/quran/sura_detaile_screen.dart';

/// Routes to the classic or modern Quran Surah Detail screen based on the saved
/// layout preference.
class SuraDetileWrapper extends StatefulWidget {
  final bool appBackButton;
  const SuraDetileWrapper({super.key, required this.appBackButton});

  @override
  State<SuraDetileWrapper> createState() => _SuraDetileWrapperState();
}

class _SuraDetileWrapperState extends State<SuraDetileWrapper> {
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
            ? ModernSuraDetileScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : SuraDetaileScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
