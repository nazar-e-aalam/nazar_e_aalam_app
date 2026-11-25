// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import '../widget/shijra_image_viewer.dart';
import '../widget/shijra_items.dart';

class ModernShijraDetailsScreen extends StatelessWidget {
  final ShijraItem item;

  const ModernShijraDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? theme.scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(title: item.titleKey.tr, isBackButtonExist: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ShijraImageViewer(imagePath: item.imagePath),
        ),
      ),
    );
  }
}
