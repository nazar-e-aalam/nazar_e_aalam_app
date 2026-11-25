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

/// Modern Hadith Books screen — glass surface, animated book list.
class ModernHadithBooksScreen extends StatelessWidget {
  final bool appBackButton;
  const ModernHadithBooksScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(HadithController());

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: "hadith_books".tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),
      body: SafeArea(
        child: GetBuilder<HadithController>(
          init: HadithController(),
          builder: (_) {
            if (controller.isLoadingHadithChapter.value) {
              return const Center(child: HadisBookShimmer());
            }

            final books = controller.hadisBookModel?.books ?? [];
            if (books.isEmpty) {
              return ModernEmptyState(
                icon: Icons.book_outlined,
                title: 'no_data_found'.tr,
                subtitle: 'hadith_books'.tr,
              );
            }

            return ModernGlassPanel(
              color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
              child: ModernAnimatedList(
                itemCount: books.length,
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.PADDING_SIZE_DEFAULT,
                  8,
                  Dimensions.PADDING_SIZE_DEFAULT,
                  Dimensions.PADDING_SIZE_EXTRA_LARGE,
                ),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return ModernListItem(
                    key: ValueKey('book_${book.bookSlug}_$index'),
                    index: index + 1,
                    title: book.bookName!,
                    subtitle: book.writerName!,
                    accentColor: Theme.of(context).primaryColor,
                    isFirst: index == 0,
                    isLast: index == books.length - 1,
                    onTap: () {
                      Get.toNamed(
                        RouteHelper.hadithChapters,
                        arguments: [book.bookSlug, book.bookName],
                      );
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
