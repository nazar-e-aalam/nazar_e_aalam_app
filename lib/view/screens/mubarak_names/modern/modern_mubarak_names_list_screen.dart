// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/mubarak_names_controller.dart';
import 'package:nazar_e_alam/data/repository/mubarak_names_repository.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'modern_mubarak_name_details_screen.dart';

class ModernMubarakNamesListScreen extends StatefulWidget {
  final MubarakNamesCategory category;

  const ModernMubarakNamesListScreen({super.key, required this.category});

  @override
  State<ModernMubarakNamesListScreen> createState() =>
      _ModernMubarakNamesListScreenState();
}

class _ModernMubarakNamesListScreenState
    extends State<ModernMubarakNamesListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Get.find<MubarakNamesController>().loadCategory(widget.category);
    });
  }

  String get title {
    switch (widget.category) {
      case MubarakNamesCategory.allah:
        return '99 Names of Allah ﷻ';
      case MubarakNamesCategory.muhammad:
        return '99 Names of Muhammad ﷺ';
      case MubarakNamesCategory.ghaus:
        return '11 Names of Ghaus-e-Azam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final language = Get.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: dark
          ? theme.scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(title: title, isBackButtonExist: true),
      body: SafeArea(
        child: GetBuilder<MubarakNamesController>(
          builder: (controller) {
            if (controller.currentCategory != widget.category ||
                controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(controller.errorMessage!),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => controller.loadCategory(widget.category),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.names.isEmpty) {
              return ModernEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'no_data_found'.tr,
                subtitle: title,
              );
            }

            return ModernGlassPanel(
              color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
              child: ModernAnimatedList(
                itemCount: controller.names.length,
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.PADDING_SIZE_DEFAULT,
                  10,
                  Dimensions.PADDING_SIZE_DEFAULT,
                  Dimensions.PADDING_SIZE_EXTRA_LARGE,
                ),
                itemBuilder: (context, index) {
                  final name = controller.names[index];

                  return ModernListItem(
                    key: ValueKey('${widget.category.name}_${name.id}'),
                    index: index + 1,
                    title: name.name(language),
                    subtitle: name.arabicName,
                    trailing: null,
                    accentColor: theme.primaryColor,
                    isFirst: index == 0,
                    isLast: index == controller.names.length - 1,
                    onTap: () {
                      Get.to(() => ModernMubarakNameDetailsScreen(name: name));
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
