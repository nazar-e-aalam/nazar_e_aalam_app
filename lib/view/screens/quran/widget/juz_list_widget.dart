// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';

import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';

import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class JuzListWidget extends StatefulWidget {
  const JuzListWidget({super.key});

  @override
  State<JuzListWidget> createState() => _JuzListWidgetState();
}

class _JuzListWidgetState extends State<JuzListWidget>
    with AutomaticKeepAliveClientMixin<JuzListWidget> {
  late final QuranController _quranController;
  late final SettingsController _settingsController;

  @override
  bool get wantKeepAlive => true;

  // ==================== INITIALIZATION ====================

  @override
  void initState() {
    super.initState();

    _quranController = Get.find<QuranController>();
    _settingsController = Get.find<SettingsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _quranController.isClosed) return;

      _loadJuzList();
    });
  }

  Future<void> _loadJuzList({bool forceRefresh = false}) async {
    if (!mounted || _quranController.isClosed) return;

    if (_quranController.isJuzListLoading.value) {
      return;
    }

    if (!forceRefresh && _quranController.juzListApiData != null) {
      return;
    }

    await _quranController.fetchJuzListData();
  }

  // ==================== MAIN WIDGET ====================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);

    return GetBuilder<QuranController>(
      builder: (quranController) {
        final juzList = quranController.juzListApiData?.data;

        // ==================== LOADING ====================

        if (quranController.isJuzListLoading.value) {
          return const Center(child: QuranListShimmer());
        }

        // ==================== ERROR ====================

        if (juzList == null) {
          return _buildErrorState(context);
        }

        // ==================== EMPTY ====================

        if (juzList.isEmpty) {
          return Center(
            child: Text(
              'no_data_found'.tr,
              style: robotoMedium.copyWith(color: theme.hintColor),
            ),
          );
        }

        // ==================== JUZ LIST ====================

        return RefreshIndicator(
          onRefresh: () => _loadJuzList(forceRefresh: true),

          child: ListView.builder(
            key: const PageStorageKey('classic_juz_list'),

            physics: const AlwaysScrollableScrollPhysics(),

            itemCount: juzList.length,

            itemBuilder: (context, juzIndex) {
              final juz = juzList[juzIndex];
              final chapters = juz.chapterList;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================== JUZ HEADER ====================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.FONT_SIZE_DEFAULT,
                    ),

                    child: Text(
                      ' ${juz.juzTranslateName}: ${juz.juzNumber}',

                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),

                  // ==================== CHAPTERS ====================
                  if (chapters != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_SMALL,
                      ),

                      child: Column(
                        children: [
                          for (final apiData in chapters)
                            GestureDetector(
                              key: ValueKey(
                                'juz_${juz.juzNumber}_'
                                '${apiData.chapterId}_'
                                '${apiData.serialNumber}',
                              ),

                              onTap: () {
                                final surahId = apiData.chapterId;

                                if (surahId == null) return;

                                _quranController.suraNumber = surahId;

                                _quranController.fetchSuraDetaileData(
                                  suraId: surahId.toString(),
                                );

                                Get.toNamed(
                                  RouteHelper.suraDetaile,
                                  arguments: 0,
                                );
                              },

                              child: Card(
                                clipBehavior: Clip.antiAlias,

                                color: theme.cardColor,

                                shadowColor: Get.isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[200]!,

                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsetsDirectional.only(
                                        start:
                                            Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                        end: Dimensions.PADDING_SIZE_SMALL,
                                      ),

                                  // ==================== SERIAL NUMBER ====================
                                  leading: Stack(
                                    alignment: Alignment.center,

                                    children: [
                                      SvgPicture.asset(
                                        Images.Icon_Star,

                                        height: 50,

                                        fit: BoxFit.fill,

                                        colorFilter: ColorFilter.mode(
                                          theme.primaryColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),

                                      Text(
                                        apiData.serialNumber.toString(),

                                        style: robotoMedium.copyWith(
                                          color:
                                              theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // ==================== TRANSLATED NAME ====================
                                  title: Obx(
                                    () => Text(
                                      apiData.translatedName.toString(),

                                      style: robotoMedium.copyWith(
                                        fontSize: _settingsController
                                            .translateFontSize
                                            .value,
                                      ),
                                    ),
                                  ),

                                  // ==================== VERSE NUMBER ====================
                                  subtitle: Obx(
                                    () => Text(
                                      '${apiData.versesTranslateName}: '
                                      '${apiData.verseNumber}',

                                      style: robotoMedium.copyWith(
                                        fontSize:
                                            (_settingsController
                                                        .translateFontSize
                                                        .value -
                                                    3)
                                                .clamp(8.0, 100.0)
                                                .toDouble(),
                                      ),
                                    ),
                                  ),

                                  // ==================== ARABIC NAME ====================
                                  trailing: Obx(
                                    () => Text(
                                      apiData.arabicName.toString(),

                                      textDirection: TextDirection.rtl,

                                      style: _settingsController
                                          .selectedArabicFont
                                          .copyWith(
                                            fontSize: _settingsController
                                                .arabicFontSize
                                                .value,

                                            color: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ==================== ERROR STATE ====================

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(Icons.auto_stories_rounded, size: 48, color: theme.hintColor),

            const SizedBox(height: 12),

            Text(
              'please_try_again'.tr,

              textAlign: TextAlign.center,

              style: robotoMedium.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: () => _loadJuzList(forceRefresh: true),

              icon: const Icon(Icons.refresh_rounded),

              label: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
