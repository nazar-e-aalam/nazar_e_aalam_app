// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

import '../model/kalima_model.dart';
import '../widget/kalima_content.dart';

class ModernKalimaDetailsScreen extends StatelessWidget {
  final KalimaModel kalima;

  const ModernKalimaDetailsScreen({
    super.key,
    required this.kalima,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: kalima.localizedTitle(kalimaLanguage()),
        isBackButtonExist: true,
      ),
      body: SafeArea(
        child: ModernGlassPanel(
          color: dark
              ? const Color(0x0AFFFFFF)
              : AppColorModern.glassFill,
          child: KalimaDetailsContent(
            kalima: kalima,
            modern: true,
          ),
        ),
      ),
    );
  }
}
