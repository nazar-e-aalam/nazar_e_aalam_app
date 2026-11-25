// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/data/model/mubarak_category_model.dart';
import 'mubarak_category_details_screen.dart';

class MubarakCategoryDetailsWrapper extends StatelessWidget {
  final MubarakCategory category;
  const MubarakCategoryDetailsWrapper({super.key, required this.category});

  @override
  Widget build(BuildContext context) => Obx(() {
    final modern =
        Get.find<HomeLayoutController>().currentLayout.value ==
        HomeLayoutController.modern;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: MubarakCategoryDetailsScreen(
        key: ValueKey(modern ? 'modern' : 'classic'),
        category: category,
        modern: modern,
      ),
    );
  });
}
