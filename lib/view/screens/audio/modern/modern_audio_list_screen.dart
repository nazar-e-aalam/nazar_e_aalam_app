// ignore_for_file: deprecated_member_use

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/audio_player_controller.dart';
import 'package:nazar_e_alam/helper/audio_service_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'package:nazar_e_alam/view/screens/audio/audio_player_sheet.dart';
import 'package:nazar_e_alam/data/model/response/reciter_surahs_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ModernAudioListScreen extends StatefulWidget {
  final bool? appBackButton;

  const ModernAudioListScreen({super.key, this.appBackButton});

  @override
  State<ModernAudioListScreen> createState() => _ModernAudioListScreenState();
}

class _ModernAudioListScreenState extends State<ModernAudioListScreen> {
  late final AudioPlayerController _controller;

  late final String reciterSlug;

  Surah? selectedSurah;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    reciterSlug = Get.arguments as String;

    _controller = Get.isRegistered<AudioPlayerController>()
        ? Get.find<AudioPlayerController>()
        : Get.put(AudioPlayerController(apiClient: Get.find()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Initialize AudioService before using the handler.
      await AudioServiceHelper.init();

      if (!mounted) return;

      await _controller.fetchSurahs(reciterSlug);
    } catch (e) {
      debugPrint('Audio initialization error: $e');

      if (mounted) {
        Get.snackbar('Error', 'Unable to initialize audio player');
      }
    }
  }

  Future<void> _selectSurah(Surah surah) async {
    setState(() {
      selectedSurah = surah;
    });

    await _controller.loadSurahAudio(reciterSlug, surah);

    if (!mounted) return;

    if (_controller.audioList.isEmpty) {
      setState(() {
        selectedSurah = null;
      });

      Get.snackbar('Error', 'No audio found for this surah');
    }
  }

  void _showSurahs() {
    setState(() {
      selectedSurah = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final reciter = _controller.reciterSurahsApiData?.reciter;

    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title:
            selectedSurah?.arabicName ?? reciter?.name ?? 'audio_list_key'.tr,
        isBackButtonExist: widget.appBackButton ?? false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isAudioLoading.value || _controller.isLoading.value) {
            return const Center(child: DhuaShimmer());
          }

          if (_controller.reciterSurahsApiData == null) {
            return _buildEmptyState();
          }

          if (selectedSurah != null) {
            return _buildAyahView(dark);
          }

          return _buildSurahView(dark);
        }),
      ),
    );
  }

  // --------------------------------------------------
  // SURAHS
  // --------------------------------------------------

  Widget _buildSurahView(bool dark) {
    final surahs = _controller.reciterSurahsApiData?.surahs ?? [];

    if (surahs.isEmpty) {
      return _buildEmptyState();
    }

    return ModernGlassPanel(
      color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];

          return ModernListItem(
            key: ValueKey('surah_${surah.number}'),
            index: surah.number ?? index + 1,
            title: surah.arabicName ?? 'Surah ${index + 1}',
            subtitle:
                '${surah.versesCount ?? 0} Ayahs • ${surah.revelationPlace ?? ''}',
            accentColor: Theme.of(context).primaryColor,
            isFirst: index == 0,
            isLast: index == surahs.length - 1,
            onTap: () => _selectSurah(surah),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // AYAH LIST
  // --------------------------------------------------

  Widget _buildAyahView(bool dark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
            vertical: Dimensions.PADDING_SIZE_SMALL,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _showSurahs,
              icon: const Icon(Icons.arrow_back),
              label: const Text('All Surahs'),
            ),
          ),
        ),
        Expanded(
          child: ModernGlassPanel(
            color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
            child: ListView.builder(
              padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
              itemCount: _controller.audioList.length,
              itemBuilder: (context, index) {
                final mediaItem = _controller.audioList[index];

                return _buildAyahItem(mediaItem, index);
              },
            ),
          ),
        ),
        _buildBottomPlayerSection(),
      ],
    );
  }

  Widget _buildAyahItem(MediaItem mediaItem, int index) {
    return ModernListItem(
      key: ValueKey('ayah_${mediaItem.id}'),
      index: index + 1,
      title: mediaItem.title,
      subtitle: mediaItem.artist ?? 'unknown_artist_key'.tr,
      accentColor: Theme.of(context).primaryColor,
      isFirst: index == 0,
      isLast: index == _controller.audioList.length - 1,
      onTap: () => _controller.playMediaItem(mediaItem),
    );
  }

  // --------------------------------------------------
  // BOTTOM PLAYER
  // --------------------------------------------------

  Widget _buildBottomPlayerSection() {
    return Obx(() {
      final mediaItem = _controller.currentMediaItem.value;

      if (mediaItem == null) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: _showFullScreenBottomSheet,
        child: _buildBottomPlayer(mediaItem),
      );
    });
  }

  void _showFullScreenBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FullScreenBottomSheet(controller: _controller);
      },
    );
  }

  Widget _buildBottomPlayer(MediaItem mediaItem) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
        vertical: Dimensions.PADDING_SIZE_SMALL,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_DEFAULT,
          vertical: Dimensions.PADDING_SIZE_SMALL,
        ),
        decoration: BoxDecoration(
          color: dark
              ? Theme.of(context).cardColor.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(
            Dimensions.RADIUS_EXTRA_LARGE + 10,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: SizedBox(
                width: 55,
                height: 55,
                child: mediaItem.artUri != null
                    ? CachedNetworkImage(
                        imageUrl: mediaItem.artUri.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildPlaceholderArt(),
                        errorWidget: (context, url, error) =>
                            _buildPlaceholderArt(),
                      )
                    : _buildPlaceholderArt(),
              ),
            ),
            const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaItem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      fontWeight: FontWeight.w600,
                      color: dark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mediaItem.artist ?? 'unknown_artist_key'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_SMALL,
                      color: dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Obx(() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _controller.skipToPrevious,
            icon: const Icon(Icons.skip_previous_rounded),
          ),
          IconButton(
            onPressed: _controller.togglePlayPause,
            icon: SvgPicture.asset(
              _controller.isPlaying.value
                  ? Images.Pause_Icon
                  : Images.Play_Icon,
              color: Theme.of(context).primaryColor,
              width: 24,
              height: 24,
            ),
          ),
          IconButton(
            onPressed: _controller.skipToNext,
            icon: const Icon(Icons.skip_next_rounded),
          ),
        ],
      );
    });
  }

  Widget _buildPlaceholderArt() {
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Icon(
        Icons.music_note,
        size: 30,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return ModernEmptyState(
      icon: Icons.music_note_outlined,
      title: 'no_audio_found_key'.tr,
      subtitle: 'no_data_found'.tr,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
