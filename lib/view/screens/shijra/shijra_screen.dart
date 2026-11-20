// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import 'shijra_details_screen.dart';
import 'widget/shijra_items.dart';

class ShijraScreen extends StatelessWidget {
  final bool appBackButton;

  const ShijraScreen({
    super.key,
    required this.appBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'shijra_mubarak'.tr,
        isBackButtonExist: appBackButton,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ShijraItems.all.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = ShijraItems.all[index];

            return Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Get.to(
                    () => ShijraDetailsScreen(item: item),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 76,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
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
