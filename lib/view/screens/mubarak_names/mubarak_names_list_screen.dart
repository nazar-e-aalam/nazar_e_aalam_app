// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/mubarak_names_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/data/repository/mubarak_names_repository.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import 'mubarak_name_details_screen.dart';

class MubarakNamesListScreen extends StatefulWidget {
  final MubarakNamesCategory category;

  const MubarakNamesListScreen({super.key, required this.category});

  @override
  State<MubarakNamesListScreen> createState() => _MubarakNamesListScreenState();
}

class _MubarakNamesListScreenState extends State<MubarakNamesListScreen> {
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
    final language = Get.locale?.languageCode ?? 'en';
    final settings = Get.find<SettingsController>();

    return Scaffold(
      appBar: CustomAppBar(title: title, isBackButtonExist: true),
      body: GetBuilder<MubarakNamesController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          if (controller.names.isEmpty) {
            return Center(child: Text('no_data_found'.tr));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
              vertical: 8,
            ),
            itemCount: controller.names.length,
            itemBuilder: (context, index) {
              final name = controller.names[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  horizontalTitleGap: 10,
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          Images.Icon_Star,
                          height: 50,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        Text(
                          translateText(name.id.toString()),
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    name.name(language),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_DEFAULT,
                    ),
                  ),
                  subtitle: Text(
                    name.meaning(language),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 115),
                    child: Text(
                      name.arabicName,
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: settings.selectedArabicFont.copyWith(
                        fontSize: settings.arabicFontSize.value,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  onTap: () {
                    Get.to(() => MubarakNameDetailsScreen(name: name));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
