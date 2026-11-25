// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

import 'modern_quran_list_item.dart';

class ModernJuzListWidget extends StatefulWidget {
  const ModernJuzListWidget({super.key});

  @override
  State<ModernJuzListWidget> createState() => _ModernJuzListWidgetState();
}

class _ModernJuzListWidgetState extends State<ModernJuzListWidget>
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

      if (controller.juzListApiData == null &&
          !controller.isJuzListLoading.value) {
        controller.fetchJuzListData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<QuranController>(
      builder: (controller) {
        return Obx(() {
          if (controller.isJuzListLoading.value) {
            return const Center(child: QuranListShimmer());
          }

          final data = controller.juzListApiData?.data;

          if (data == null) {
            return Center(
              child: TextButton.icon(
                onPressed: () {
                  controller.fetchJuzListData();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text('please_try_again'.tr),
              ),
            );
          }

          if (data.isEmpty) {
            return ModernEmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'juz_list'.tr,
              subtitle: 'no_data_found'.tr,
            );
          }

          final builders = <WidgetBuilder>[];

          for (final juz in data) {
            builders.add(
              (context) => _buildJuzHeader(
                context,
                '${juz.juzTranslateName}: ${juz.juzNumber}',
              ),
            );

            final chapters = juz.chapterList;

            if (chapters == null) continue;

            for (final chapter in chapters) {
              builders.add(
                (context) => ModernQuranListItem(
                  key: ValueKey(
                    'juz_${juz.juzNumber}_'
                    '${chapter.chapterId}_'
                    '${chapter.serialNumber}',
                  ),
                  number: chapter.serialNumber.toString(),
                  title: chapter.translatedName?.toString() ?? '',
                  subtitle:
                      '${chapter.versesTranslateName}: '
                      '${chapter.verseNumber}',
                  arabicName: chapter.arabicName?.toString() ?? '',
                  onTap: () {
                    controller.suraNumber = chapter.chapterId;

                    controller.fetchSuraDetaileData(
                      suraId: chapter.chapterId.toString(),
                    );

                    Get.toNamed(RouteHelper.suraDetaile, arguments: 0);
                  },
                ),
              );
            }
          }

          return ModernAnimatedList(
            key: const PageStorageKey('modern_juz_list'),
            itemCount: builders.length + 1,
            padding: const EdgeInsets.fromLTRB(
              Dimensions.PADDING_SIZE_DEFAULT,
              8,
              Dimensions.PADDING_SIZE_DEFAULT,
              Dimensions.PADDING_SIZE_EXTRA_LARGE,
            ),
            itemBuilder: (context, index) {
              if (index == builders.length) {
                return const SizedBox(height: 80);
              }

              return builders[index](context);
            },
          );
        });
      },
    );
  }

  Widget _buildJuzHeader(BuildContext context, String title) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_stories_rounded, color: primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: robotoBold.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
