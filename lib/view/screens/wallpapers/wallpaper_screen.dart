// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/screens/wallpapers/widget/wallpaper_grid.dart';

class WallpaperScreens extends StatelessWidget {
  final bool? appBackButton;

  const WallpaperScreens({super.key, this.appBackButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'wallpapers_key'.tr,
        isBackButtonExist: appBackButton == true,
      ),
      body: const SafeArea(child: WallpaperGrid()),
    );
  }
}
