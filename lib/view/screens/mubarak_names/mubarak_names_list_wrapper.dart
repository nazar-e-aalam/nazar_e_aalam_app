// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/data/repository/mubarak_names_repository.dart';

import 'mubarak_names_list_screen.dart';
import 'modern/modern_mubarak_names_list_screen.dart';

class MubarakNamesListWrapper extends StatelessWidget {
  final MubarakNamesCategory category;

  const MubarakNamesListWrapper({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final modern =
          Get.find<HomeLayoutController>().currentLayout.value ==
          HomeLayoutController.modern;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: modern
            ? ModernMubarakNamesListScreen(
                key: ValueKey('modern_${category.name}'),
                category: category,
              )
            : MubarakNamesListScreen(
                key: ValueKey('classic_${category.name}'),
                category: category,
              ),
      );
    });
  }
}
