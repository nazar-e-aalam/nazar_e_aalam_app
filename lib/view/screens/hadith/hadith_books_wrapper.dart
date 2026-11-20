// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/hadith/hadis_book_name_screen.dart';
import 'package:nazar_e_alam/view/screens/hadith/modern/modern_hadith_books_screen.dart';

/// Routes to the classic or modern Hadith Books screen based on the saved
/// layout preference.
class HadithBooksWrapper extends StatefulWidget {
  final bool appBackButton;
  const HadithBooksWrapper({super.key, required this.appBackButton});

  @override
  State<HadithBooksWrapper> createState() => _HadithBooksWrapperState();
}

class _HadithBooksWrapperState extends State<HadithBooksWrapper> {
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
            ? ModernHadithBooksScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : HadisBookNameScreen(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
