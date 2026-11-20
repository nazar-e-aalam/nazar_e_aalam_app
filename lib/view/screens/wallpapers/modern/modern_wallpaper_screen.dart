// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'package:nazar_e_alam/view/screens/wallpapers/widget/wallpaper_grid.dart';

class ModernWallpaperScreens extends StatelessWidget {
  final bool? appBackButton;

  const ModernWallpaperScreens({
    super.key,
    this.appBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'wallpapers_key'.tr,
        isBackButtonExist: appBackButton == true,
      ),
      body: SafeArea(
        child: ModernGlassPanel(
          color: dark
              ? const Color(0x0AFFFFFF)
              : AppColorModern.glassFill,
          child: const WallpaperGrid(modern: true),
        ),
      ),
    );
  }
}

