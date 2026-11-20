// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

import '../../../../controller/hadith_controller.dart';
import '../../../../helper/route_helper.dart';

/// Modern Hadith Chapters screen — glass surface, animated chapter list.
class ModernHadithChaptersScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernHadithChaptersScreen({super.key, required this.appBackButton});

  @override
  State<ModernHadithChaptersScreen> createState() =>
      _ModernHadithChaptersScreenState();
}

class _ModernHadithChaptersScreenState
    extends State<ModernHadithChaptersScreen> {
  late final HadithController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(HadithController());
    _controller.getHadithBookChaptersData(Get.arguments[0]);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final title = "${Get.arguments[1]} ${"chapters".tr}";
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: title,
        isBackButtonExist: widget.appBackButton == true ? true : false,
      ),
      body: SafeArea(
        child: GetBuilder<HadithController>(
          builder: (_) {
            if (_controller.isLoadingHadithChapter.value) {
              return const Center(child: HadisChapterShimmer());
            }

            final chapters = _controller.hadithChapterModel?.chapters ?? [];
            if (chapters.isEmpty) {
              return ModernEmptyState(
                icon: Icons.book_outlined,
                title: 'no_data_found'.tr,
                subtitle: 'chapters'.tr,
              );
            }

            return ModernGlassPanel(
              color: dark
                  ? const Color(0x0AFFFFFF)
                  : AppColorModern.glassFill,
              child: ModernAnimatedList(
                itemCount: chapters.length,
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.PADDING_SIZE_DEFAULT,
                  8,
                  Dimensions.PADDING_SIZE_DEFAULT,
                  Dimensions.PADDING_SIZE_EXTRA_LARGE,
                ),
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  return ModernListItem(
                    key: ValueKey('chapter_${chapter.chapterNumber}_$index'),
                    index: index + 1,
                    title: chapter.chapterEnglish ?? "",
                    subtitle: chapter.chapterArabic != null &&
                            chapter.chapterArabic!.isNotEmpty
                        ? chapter.chapterArabic
                        : null,
                    accentColor: Theme.of(context).primaryColor,
                    isFirst: index == 0,
                    isLast: index == chapters.length - 1,
                    onTap: () {
                      Get.toNamed(RouteHelper.allHadith, arguments: [
                        Get.arguments[1],
                        chapter.bookSlug,
                        chapter.chapterNumber,
                      ]);
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
