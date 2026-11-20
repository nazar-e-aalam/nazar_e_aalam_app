// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nazar_e_alam/controller/wallpaper_controller.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/view/screens/wallpapers/widget/set_wallpaper_dialog.dart';

class WallpaperGrid extends StatefulWidget {
  final bool modern;

  const WallpaperGrid({super.key, this.modern = false});

  @override
  State<WallpaperGrid> createState() => _WallpaperGridState();
}

class _WallpaperGridState extends State<WallpaperGrid> {
  late final WallPaperController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = Get.find<WallPaperController>();
    scrollController = ScrollController();

    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.wallpaperCategoryListData();
      }
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.extentAfter < 500) {
      controller.loadMoreWallpapers();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<WallPaperController>(
      builder: (wallPaperController) {
        final loading = wallPaperController.isWallPaperListLoading.value;

        final wallpapers = wallPaperController.wallpaperModelData?.data;

        if (loading && wallpapers == null) {
          return const WallpaperListTypeShimmer();
        }

        if (wallpapers == null || wallpapers.isEmpty) {
          return Center(child: Text('no_data_found'.tr));
        }

        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          displacement: 45,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: () async {
            await wallPaperController.wallpaperCategoryListData(refresh: true);
          },
          child: GridView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount:
                wallpapers.length +
                (wallPaperController.isLoadingMoreWallpapers.value ? 1 : 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.57,
            ),
            itemBuilder: (context, index) {
              if (index >= wallpapers.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final wallpaper = wallpapers[index];
              final imageUrl = wallpaper.image ?? '';

              return InkWell(
                borderRadius: BorderRadius.circular(widget.modern ? 18 : 14),
                onTap: imageUrl.isEmpty
                    ? null
                    : () {
                        Get.dialog(
                          SetWallpaperDialogWidget(imagePath: imageUrl),
                        );
                      },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            widget.modern ? 18 : 14,
                          ),
                          border: Border.all(
                            color: theme.primaryColor.withValues(
                              alpha: widget.modern ? 0.18 : 0.12,
                            ),
                          ),
                        ),
                        child: imageUrl.isEmpty
                            ? const Center(
                                child: Icon(Icons.image_not_supported_outlined),
                              )
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: 450,
                                placeholder: (_, _) => Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.25),
                                  ),
                                ),
                                errorWidget: (_, _, _) => const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      wallpaper.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
