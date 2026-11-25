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

class SuraListWidget extends StatefulWidget {
  const SuraListWidget({super.key});

  @override
  State<SuraListWidget> createState() => _SuraListWidgetState();
}

class _SuraListWidgetState extends State<SuraListWidget>
    with AutomaticKeepAliveClientMixin<SuraListWidget> {
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

      _loadSurahList();
    });
  }

  Future<void> _loadSurahList({bool forceRefresh = false}) async {
    if (!mounted || _quranController.isClosed) return;

    if (_quranController.isSuraListLoading.value) {
      return;
    }

    if (!forceRefresh && _quranController.suraListApiData != null) {
      return;
    }

    await _quranController.fetchSuraListData();
  }

  // ==================== MAIN WIDGET ====================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);

    return GetBuilder<QuranController>(
      builder: (quranController) {
        final surahs = quranController.suraListApiData?.data;

        // Loading state.
        if (quranController.isSuraListLoading.value) {
          return const Center(child: QuranListShimmer());
        }

        // Error state.
        if (surahs == null) {
          return _buildErrorState(context);
        }

        // Empty state.
        if (surahs.isEmpty) {
          return Center(
            child: Text(
              'no_data_found'.tr,
              style: robotoMedium.copyWith(color: theme.hintColor),
            ),
          );
        }

        // Surah list.
        return RefreshIndicator(
          onRefresh: () => _loadSurahList(forceRefresh: true),

          child: ListView.builder(
            key: const PageStorageKey('classic_surah_list'),

            primary: false,

            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_SMALL,
            ),

            itemCount: surahs.length,

            itemBuilder: (context, index) {
              final apiData = surahs[index];

              return GestureDetector(
                key: ValueKey('classic_surah_${apiData.id}'),

                onTap: () {
                  final surahId = apiData.id;

                  if (surahId == null) return;

                  _quranController.suraNumber = surahId;

                  _quranController.fetchSuraDetaileData(
                    suraId: surahId.toString(),
                  );

                  Get.toNamed(RouteHelper.suraDetaile, arguments: 0);
                },

                child: Card(
                  clipBehavior: Clip.antiAlias,

                  color: theme.cardColor,

                  shadowColor: Get.isDarkMode
                      ? Colors.grey[800]!
                      : Colors.grey[200]!,

                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
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
                            fontSize: Dimensions.FONT_SIZE_SMALL,

                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),

                    // ==================== TRANSLATED NAME ====================
                    title: Obx(
                      () => Text(
                        apiData.translateName.toString(),

                        style: robotoMedium.copyWith(
                          fontSize: _settingsController.translateFontSize.value,
                        ),
                      ),
                    ),

                    // ==================== VERSES COUNT ====================
                    subtitle: Obx(
                      () => Text(
                        '${apiData.versesTranslateName}: '
                        '${apiData.versesCount}',

                        style: robotoMedium.copyWith(
                          fontSize:
                              (_settingsController.translateFontSize.value - 3)
                                  .clamp(8.0, 100.0)
                                  .toDouble(),

                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),

                    // ==================== ARABIC NAME ====================
                    trailing: Obx(
                      () => Text(
                        apiData.arabicName.toString(),

                        textDirection: TextDirection.rtl,

                        style: _settingsController.selectedArabicFont.copyWith(
                          fontSize: _settingsController.arabicFontSize.value,

                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ),
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
            Icon(Icons.menu_book_rounded, size: 48, color: theme.hintColor),

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
              onPressed: () => _loadSurahList(forceRefresh: true),

              icon: const Icon(Icons.refresh_rounded),

              label: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
