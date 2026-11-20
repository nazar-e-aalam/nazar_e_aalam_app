// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nazar_e_alam/controller/audio_player_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

class ModernRecitersScreen extends StatefulWidget {
  final bool? appBackButton;

  const ModernRecitersScreen({
    super.key,
    this.appBackButton,
  });

  @override
  State<ModernRecitersScreen> createState() =>
      _ModernRecitersScreenState();
}

class _ModernRecitersScreenState extends State<ModernRecitersScreen> {
  late final AudioPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<AudioPlayerController>()
        ? Get.find<AudioPlayerController>()
        : Get.put(AudioPlayerController(apiClient: Get.find()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.fetchReciterData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'all_reciters_key'.tr,
        isBackButtonExist: widget.appBackButton == true,
      ),
      body: SafeArea(
        child: GetBuilder<AudioPlayerController>(
          builder: (audioController) {
            if (audioController.isRecitersLoading.value) {
              return const Center(child: DhuaShimmer());
            }

            final data = audioController.recitersListApiData?.data;

            if (data == null || data.isEmpty) {
              return ModernEmptyState(
                icon: Icons.person_outline,
                title: 'no_name_found_key'.tr,
                subtitle: 'no_data_found'.tr,
              );
            }

            return ModernGlassPanel(
              color: dark
                  ? const Color(0x0AFFFFFF)
                  : AppColorModern.glassFill,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.PADDING_SIZE_DEFAULT,
                  8,
                  Dimensions.PADDING_SIZE_DEFAULT,
                  Dimensions.PADDING_SIZE_EXTRA_LARGE,
                ),
                itemCount: data.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final reciter = data[index];

                  return _ReciterGradientCard(
                    key: ValueKey('reciter_${reciter.slug}_$index'),
                    name: reciter.name ?? 'no_name_found_key'.tr,
                    imageUrl: reciter.profilePicture,
                    index: index + 1,
                    onTap: () {
                      Get.toNamed(
                        RouteHelper.audioList,
                        arguments: reciter.slug,
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

class _ReciterGradientCard extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final int index;
  final VoidCallback onTap;

  const _ReciterGradientCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ReciterGradientCard> createState() =>
      _ReciterGradientCardState();
}


class _ReciterGradientCardState extends State<_ReciterGradientCard> {
  Color? extractedColor;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  @override
  void didUpdateWidget(covariant _ReciterGradientCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrl != widget.imageUrl) {
      extractedColor = null;
      _extractColor();
    }
  }

  Future<void> _extractColor() async {
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) return;

    try {
      final scheme = await ColorScheme.fromImageProvider(
        provider: CachedNetworkImageProvider(url),
        brightness: Brightness.light,
      );

      if (!mounted || widget.imageUrl != url) return;

      setState(() {
        extractedColor = scheme.primary;
      });
    } catch (e) {
      debugPrint('Reciter image color extraction failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    final surface = theme.cardColor;
    final imageColor = extractedColor ?? theme.primaryColor;

    Color blend(double opacity) {
      return Color.alphaBlend(
        imageColor.withValues(alpha: opacity),
        surface,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.25, 0.60, 1.0],
              colors: [
                blend(dark ? 0.80 : 0.65),
                blend(dark ? 0.60 : 0.45),
                blend(dark ? 0.32 : 0.22),
                surface,
              ],
            ),
            border: Border.all(
              color: imageColor.withValues(alpha: 0.30),
              width: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: widget.imageUrl != null &&
                            widget.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: imageColor.withValues(alpha: 0.15),
                              child: const Icon(Icons.person),
                            ),
                            errorWidget: (_, _, _) => Image.asset(
                              Images.Reciter_Person,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            Images.Reciter_Person,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.65),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
