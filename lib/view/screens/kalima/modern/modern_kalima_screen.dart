// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

import '../widget/kalima_content.dart';
import 'modern_kalima_details_screen.dart';

class ModernKalimaScreen extends StatelessWidget {
  final bool? appBackButton;

  const ModernKalimaScreen({
    super.key,
    this.appBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'Kalima Sharif',
        isBackButtonExist: appBackButton == true,
      ),
      body: SafeArea(
        child: ModernGlassPanel(
          color: dark
              ? const Color(0x0AFFFFFF)
              : AppColorModern.glassFill,
          child: KalimaListContent(
            modern: true,
            onSelected: (kalima) {
              Get.to(
                () => ModernKalimaDetailsScreen(
                  kalima: kalima,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
