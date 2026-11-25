// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

import 'modern_quran_list_item.dart';

class ModernSuraListWidget extends StatefulWidget {
  const ModernSuraListWidget({super.key});

  @override
  State<ModernSuraListWidget> createState() => _ModernSuraListWidgetState();
}

class _ModernSuraListWidgetState extends State<ModernSuraListWidget>
    with AutomaticKeepAliveClientMixin {
  late final QuranController controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    controller = Get.find<QuranController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (controller.suraListApiData == null &&
          !controller.isSuraListLoading.value) {
        controller.fetchSuraListData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<QuranController>(
      builder: (controller) {
        return Obx(() {
          if (controller.isSuraListLoading.value) {
            return const Center(child: QuranListShimmer());
          }

          final data = controller.suraListApiData?.data;

          if (data == null) {
            return Center(
              child: TextButton.icon(
                onPressed: () {
                  controller.fetchSuraListData();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text('please_try_again'.tr),
              ),
            );
          }

          if (data.isEmpty) {
            return ModernEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'no_surahs_found'.tr,
              subtitle: 'no_data_found'.tr,
            );
          }

          return ModernAnimatedList(
            key: const PageStorageKey('modern_surah_list'),
            itemCount: data.length + 1,
            padding: const EdgeInsets.fromLTRB(
              Dimensions.PADDING_SIZE_DEFAULT,
              8,
              Dimensions.PADDING_SIZE_DEFAULT,
              Dimensions.PADDING_SIZE_EXTRA_LARGE,
            ),
            itemBuilder: (context, index) {
              if (index == data.length) {
                return const SizedBox(height: 80);
              }

              final item = data[index];

              return ModernQuranListItem(
                key: ValueKey('surah_${item.id}'),
                number: item.serialNumber.toString(),
                title: item.translateName?.toString() ?? '',
                subtitle:
                    '${item.versesTranslateName}: '
                    '${item.versesCount}',
                arabicName: item.arabicName?.toString() ?? '',
                onTap: () {
                  controller.suraNumber = item.id;

                  controller.fetchSuraDetaileData(suraId: item.id.toString());

                  Get.toNamed(RouteHelper.suraDetaile, arguments: 0);
                },
              );
            },
          );
        });
      },
    );
  }
}
