// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/bookmark_controller.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';

import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

import 'package:nazar_e_alam/view/base/custom_snackbar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/offline_surah_detail_screen.dart';

class ModernBookmarkTab extends StatefulWidget {
  const ModernBookmarkTab({super.key});

  @override
  State<ModernBookmarkTab> createState() => _ModernBookmarkTabState();
}

class _ModernBookmarkTabState extends State<ModernBookmarkTab>
    with AutomaticKeepAliveClientMixin {
  late final BookMarkController bookmarkController;
  late final InternetController internetController;
  late final SettingsController settingsController;

  bool _deleting = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    bookmarkController = Get.isRegistered<BookMarkController>()
        ? Get.find<BookMarkController>()
        : Get.put(BookMarkController());

    internetController = Get.isRegistered<InternetController>()
        ? Get.find<InternetController>()
        : Get.put(InternetController());

    settingsController = Get.find<SettingsController>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      if (bookmarkController.isLoading.value) {
        return const Center(child: QuranListShimmer());
      }

      final bookmarks = bookmarkController.bookMarks.toList();

      if (bookmarks.isEmpty) {
        return ModernEmptyState(
          icon: Icons.bookmark_border_rounded,
          title: 'bookmark'.tr,
          subtitle: 'no_bookmarks_have_been_added_here'.tr,
        );
      }

      return ModernAnimatedList(
        key: const PageStorageKey('modern_bookmarks'),
        itemCount: bookmarks.length + 1,
        padding: const EdgeInsets.fromLTRB(
          Dimensions.PADDING_SIZE_DEFAULT,
          8,
          Dimensions.PADDING_SIZE_DEFAULT,
          Dimensions.PADDING_SIZE_EXTRA_LARGE,
        ),
        itemBuilder: (context, index) {
          if (index == bookmarks.length) {
            return const SizedBox(height: 80);
          }

          final bookmark = bookmarks[index];

          return _buildBookmarkCard(
            context: context,
            key: ValueKey('bookmark_${bookmark.id}'),
            arabicText: bookmark.arabicName,
            translation: bookmark.translatedName,
            surahName: bookmark.suraName,
            surahNumber: bookmark.serialNumber.toString(),
            ayahNumber: bookmark.versesNumber.toString(),
            pageNumber: bookmark.pageNumber.toString(),
            onTap: () {
              final surahNumber = int.tryParse(
                bookmark.serialNumber.toString(),
              );

              final pageKey = int.tryParse(bookmark.pageKey.toString());

              if (surahNumber == null || pageKey == null) {
                showCustomSnackBar('please_try_again'.tr, isError: true);
                return;
              }

              if (!internetController.hasInternet.value) {
                Get.to(
                  () => OfflineSuraDetaileScreen(
                    appBackButton: true,
                    surahNumber: bookmark.serialNumber,
                  ),
                  arguments: pageKey,
                );

                return;
              }

              final quranController = Get.find<QuranController>();

              quranController.suraNumber = surahNumber;

              quranController.fetchSuraDetaileData(
                suraId: surahNumber.toString(),
              );

              Get.toNamed(RouteHelper.suraDetaile, arguments: bookmark.pageKey);
            },
            onDelete: () async {
              if (_deleting) return;

              _deleting = true;

              try {
                final confirmed = await _confirmDelete(context);

                if (confirmed != true || !mounted) {
                  return;
                }

                await Future.sync(
                  () => bookmarkController.deleteBookMark(bookmark.id),
                );
              } catch (e) {
                debugPrint('Bookmark deletion error: $e');

                if (mounted) {
                  showCustomSnackBar('please_try_again'.tr, isError: true);
                }
              } finally {
                _deleting = false;
              }
            },
          );
        },
      );
    });
  }

  // ==================== BOOKMARK CARD ====================

  Widget _buildBookmarkCard({
    required BuildContext context,
    required Key key,
    required String arabicText,
    required String translation,
    required String surahName,
    required String surahNumber,
    required String ayahNumber,
    required String pageNumber,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => Text(
                          surahName,
                          style: robotoBold.copyWith(
                            fontSize:
                                settingsController.translateFontSize.value,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Obx(
                    () => Text(
                      arabicText,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: settingsController.selectedArabicFont.copyWith(
                        fontSize: settingsController.arabicFontSize.value,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Obx(
                  () => Text(
                    translation,
                    style: robotoRegular.copyWith(
                      fontSize: settingsController.translateFontSize.value,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Divider(color: primary.withValues(alpha: 0.12)),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoTag(context, '${'sura_number'.tr}: $surahNumber'),
                    if (ayahNumber.isNotEmpty)
                      _buildInfoTag(context, '${'ayah_no'.tr}: $ayahNumber'),
                    _buildInfoTag(context, '${'page_no'.tr}: $pageNumber'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(BuildContext context, String label) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(
        () => Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: (settingsController.translateFontSize.value - 3)
                .clamp(10.0, 100.0)
                .toDouble(),
            color: primary,
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Icon(
            Icons.delete_outline_rounded,
            color: theme.colorScheme.error,
            size: 36,
          ),
          title: Text('are_you_sure'.tr),
          content: Text(
            'do_you_want_to_delete_this_bookmark'.tr,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('cancel'.tr),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text('yes'.tr),
            ),
          ],
        );
      },
    );
  }
}
