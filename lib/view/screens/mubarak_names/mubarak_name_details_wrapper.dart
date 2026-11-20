// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/data/model/mubarak_name_model.dart';

import 'mubarak_name_details_screen.dart';
import 'modern/modern_mubarak_name_details_screen.dart';

class MubarakNameDetailsWrapper extends StatelessWidget {
  final MubarakName name;

  const MubarakNameDetailsWrapper({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final modern =
          Get.find<HomeLayoutController>().currentLayout.value ==
          HomeLayoutController.modern;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: modern
            ? ModernMubarakNameDetailsScreen(
                key: const ValueKey('modern_detail'),
                name: name,
              )
            : MubarakNameDetailsScreen(
                key: const ValueKey('classic_detail'),
                name: name,
              ),
      );
    });
  }
}
