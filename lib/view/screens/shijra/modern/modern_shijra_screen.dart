// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import '../widget/shijra_items.dart';
import 'modern_shijra_details_screen.dart';

class ModernShijraScreen extends StatelessWidget {
  final bool appBackButton;

  const ModernShijraScreen({
    super.key,
    required this.appBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    return Scaffold(
      backgroundColor: dark
          ? theme.scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'shijra_mubarak'.tr,
        isBackButtonExist: appBackButton,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ShijraItems.all.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = ShijraItems.all[index];

            return Material(
              color: dark
                  ? theme.colorScheme.surface
                  : AppColorModern.glassFill,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  Get.to(
                    () => ModernShijraDetailsScreen(item: item),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 95,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          item.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.titleKey.tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 17,
                        color: primary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
