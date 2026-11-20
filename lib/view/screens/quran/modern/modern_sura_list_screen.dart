// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

/// Modern Quran Surah list screen.
///
/// Glass surface, gradient header card, animated rank-chipped surah items
/// with Arabic name badge instead of the generic Card + ListTile.
class ModernSuraListScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernSuraListScreen({super.key, required this.appBackButton});

  @override
  State<ModernSuraListScreen> createState() => _ModernSuraListScreenState();
}

class _ModernSuraListScreenState extends State<ModernSuraListScreen> {
  late final QuranController _quranController;

  @override
  void initState() {
    super.initState();
    _quranController = Get.find<QuranController>();

    // Defer API fetch until after build to avoid setState-during-build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quranController.fetchSuraListData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: "holy_quran".tr,
        isBackButtonExist: widget.appBackButton,
        actions: [
          IconButton(
            onPressed: () {
              // open quran settings bottom sheet
            },
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<QuranController>(
          builder: (quranController) {
            if (quranController.isSuraListLoading.value) {
              return const Center(child: QuranListShimmer());
            }

            if (quranController.suraListApiData?.data == null) {
              return ModernEmptyState(
                icon: Icons.error_outline,
                title: 'Unable to load Surahs',
                subtitle: 'Please try again',
              );
            }

            final data = quranController.suraListApiData!.data!;
            if (data.isEmpty) {
              return ModernEmptyState(
                icon: Icons.book_outlined,
                title: 'no_surahs_found'.tr,
                subtitle: 'no_data_found'.tr,
              );
            }
            final surahcount = data.length;
            return ModernGlassPanel(
              color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
              child: Column(
                children: [
                  _buildHeaderCard(context, data.length),
                  Expanded(
                    child: ModernAnimatedList(
                      itemCount: surahcount + 1,
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.PADDING_SIZE_DEFAULT,
                        8,
                        Dimensions.PADDING_SIZE_DEFAULT,
                        Dimensions.PADDING_SIZE_EXTRA_LARGE,
                      ),
                      itemBuilder: (context, index) {
                        if (index == surahcount) {
                          return SizedBox(height: 80);
                        }
                        final item = data[index];
                        return ModernListItem(
                          key: ValueKey('sura_${item.id}_$index'),
                          index: index + 1,
                          title: item.translateName?.toString() ?? "",
                          subtitle:
                              "${item.versesTranslateName}: ${item.versesCount}",
                          trailing: item.arabicName?.toString(),
                          accentColor: Theme.of(context).primaryColor,
                          isFirst: index == 0,
                          isLast: index == data.length - 1,
                          onTap: () {
                            _quranController.suraNumber = item.id;
                            _quranController.fetchSuraDetaileData(
                              suraId: item.id.toString(),
                            );
                            Get.toNamed(RouteHelper.suraDetaile, arguments: 0);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, int count) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [const Color(0xFF2B1D13), const Color(0xFF3A2E24)]
                : [
                    Theme.of(context).primaryColor,
                    AppColorModern.primaryColorDark,
                  ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "holy_quran".tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ModernTag(
                            label: count.toString(),
                            color: Colors.green.shade500,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "surahs".tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_SMALL,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "tap_any_surah_to_read".tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.FONT_SIZE_SMALL,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
