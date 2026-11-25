// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
// import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

import '../alphabet_setting_sheet.dart';
import '../widget/arabic_alphabet_grid.dart';

class ModernAlphabetScreen extends StatelessWidget {
  final bool? appBackButton;

  const ModernAlphabetScreen({super.key, this.appBackButton});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        isBackButtonExist: appBackButton == true,
        title: 'alphabet_key'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => openAlphabetSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ModernGlassPanel(
            color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(
                //     Dimensions.PADDING_SIZE_DEFAULT,
                //     Dimensions.PADDING_SIZE_DEFAULT,
                //     Dimensions.PADDING_SIZE_DEFAULT,
                //     16,
                //   ),
                // ),

                ArabicAlphabetGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
