// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/hadith_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

/// Modern All Hadith screen.
///
/// Glass surface, saffron gradient header, animated rank-chipped list items
/// instead of the generic Card + ListTile used by classic.
class ModernAllHadithScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernAllHadithScreen({super.key, required this.appBackButton});

  @override
  State<ModernAllHadithScreen> createState() => _ModernAllHadithScreenState();
}

class _ModernAllHadithScreenState extends State<ModernAllHadithScreen> {
  late final HadithController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(HadithController());
    _controller.getAllHadithData(Get.arguments[1], Get.arguments[2]);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final title = "${Get.arguments[0]} ${"hadith".tr}";

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: title,
        isBackButtonExist: widget.appBackButton,
      ),
      body: GetBuilder<HadithController>(
        builder: (_) {
          if (_controller.isLoadingHadith.value) {
            return const SafeArea(child: Center(child: HadisChapterShimmer()));
          }

          final data = _controller.hadithModel?.hadiths?.data;

          if (data == null || data.isEmpty) {
            return SafeArea(
              child: ModernEmptyState(
                icon: Icons.book_outlined,
                title: 'no_hadith_found'.tr,
                subtitle: 'no_hadith_found_in_this_chapter'.tr,
              ),
            );
          }

          return SafeArea(
            child: ModernGlassPanel(
              color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
              child: Column(
                children: [
                  // Header card with book info + count
                  _buildHeaderCard(context, data.length),
                  const SizedBox(height: 10),
                  // Animated list
                  Expanded(
                    child: ModernAnimatedList(
                      itemCount: data.length,
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.PADDING_SIZE_DEFAULT,
                        0,
                        Dimensions.PADDING_SIZE_DEFAULT,
                        Dimensions.PADDING_SIZE_EXTRA_LARGE,
                      ),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final writer =
                            item.book?.writerName ??
                            "${"writer".tr}: ${item.englishNarrator ?? ""}";
                        return ModernListItem(
                          key: ValueKey('hadith_${item.id}_$index'),
                          index: index + 1,
                          title: item.hadithEnglish ?? "",
                          subtitle: writer.isEmpty
                              ? null
                              : "${"writer".tr}: $writer",
                          accentColor: Theme.of(context).primaryColor,
                          isFirst: index == 0,
                          isLast: index == data.length - 1,
                          onTap: () {
                            Get.toNamed(
                              RouteHelper.hadithDetails,
                              arguments: item,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Colors.white.withValues(alpha: 0.4),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.book_outlined,
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
                        "${Get.arguments[0]} ${"hadith".tr}",
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
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "hadiths".tr,
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
              "tap_any_hadith_to_read".tr,
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
