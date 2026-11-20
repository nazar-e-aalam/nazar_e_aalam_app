// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/wallpapers/modern/modern_wallpaper_screen.dart';
import 'package:nazar_e_alam/view/screens/wallpapers/wallpaper_screen.dart';

/// Routes to the classic or modern Wallpapers screen based on the saved
/// layout preference.
class WallpaperWrapper extends StatefulWidget {
  final bool? appBackButton;
  const WallpaperWrapper({super.key, this.appBackButton});

  @override
  State<WallpaperWrapper> createState() => _WallpaperWrapperState();
}

class _WallpaperWrapperState extends State<WallpaperWrapper> {
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
            ? ModernWallpaperScreens(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : WallpaperScreens(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
