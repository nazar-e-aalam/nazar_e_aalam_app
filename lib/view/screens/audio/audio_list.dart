// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/audio_player_controller.dart';
import 'package:nazar_e_alam/data/model/response/reciter_surahs_model.dart';
import 'package:nazar_e_alam/helper/audio_service_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/screens/audio/audio_player_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../util/dimensions.dart';

class AudioPlayerView extends StatefulWidget {
  final bool? appBackButton;
  final String reciterSlug;

  AudioPlayerView({super.key, this.appBackButton})
    : reciterSlug = Get.arguments.toString();

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  final AudioPlayerController _controller = Get.put(
    AudioPlayerController(apiClient: Get.find()),
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeAndLoadSurahs();
    });
  }

  Future<void> _initializeAndLoadSurahs() async {
    _controller.isLoading.value = true;

    try {
      await AudioServiceHelper.init();

      await _controller.fetchSurahs(widget.reciterSlug);
    } catch (error) {
      if (kDebugMode) {
        print('Error initializing audio or loading surahs: $error');
      }
    } finally {
      _controller.isLoading.value = false;
    }
  }

  Future<void> initializeAudioService() async {
    try {
      _controller.isLoading.value = true;
      _controller.audioList.clear();
      await AudioServiceHelper.init();
    } catch (error) {
      if (kDebugMode) {
        print('Error initializing AudioService: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "audio_list_key".tr,
        isBackButtonExist: widget.appBackButton ?? false,
      ),
      body: Obx(() {
        if (_controller.isAudioLoading.value || _controller.isLoading.value) {
          return const Center(child: DhuaShimmer());
        }

        final surahs = _controller.reciterSurahsApiData?.surahs ?? [];

        if (surahs.isEmpty) {
          return _buildEmptyAudioList();
        }

        return _buildAudioListWithPlayer();
      }),
    );
  }

  Widget _buildEmptyAudioList() {
    return Center(
      child: Text(
        "no_audio_found_key".tr,
        style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
      ),
    );
  }

  Widget _buildAudioListWithPlayer() {
    return Column(
      children: [
        Expanded(child: _buildAudioList()),
        _buildBottomPlayerSection(),
      ],
    );
  }

  Widget _buildAudioList() {
    final surahs = _controller.reciterSurahsApiData?.surahs ?? [];

    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return _buildAudioListItem(surah);
      },
    );
  }

  Widget _buildAudioListItem(Surah surah) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: CircleAvatar(child: Text('${surah.number ?? ''}')),
          title: Text(
            surah.arabicName ?? '',
            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
          ),
          subtitle: Text(
            '${surah.versesCount ?? 0} verses • ${surah.revelationPlace ?? ''}',
            style: robotoMedium.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          onTap: () {
            _controller.loadSurahAudio(widget.reciterSlug, surah);
          },
        ),
      ),
    );
  }

  Widget _buildBottomPlayerSection() {
    return Obx(() {
      final mediaItem = _controller.currentMediaItem.value;
      if (mediaItem == null) return const SizedBox.shrink();

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
      builder: (context) => FullScreenBottomSheet(controller: _controller),
    );
  }

  Widget _buildBottomPlayer(MediaItem mediaItem) {
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
          color: Get.isDarkMode
              ? Theme.of(context).cardColor.withOpacity(0.95)
              : Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(
            Dimensions.RADIUS_EXTRA_LARGE + 10,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Album Art with Neumorphic Effect
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Get.isDarkMode
                        ? Colors.black.withOpacity(0.6)
                        : Colors.grey.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                  BoxShadow(
                    color: Get.isDarkMode
                        ? Colors.grey[800]!.withOpacity(0.4)
                        : Colors.white.withOpacity(0.8),
                    blurRadius: 10,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Get.isDarkMode ? Colors.grey[850] : Colors.grey[100],
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
            ),

            const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),

            // Media Info
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
                      color: Get.isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mediaItem.artist ?? 'unknown_artist_key'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_SMALL,
                      color: Get.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Modern Controls
            _buildModernControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderArt() {
    return Center(
      child: Icon(
        Icons.music_note,
        size: 30,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildModernControlButtons() {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous Button
            IconButton(
              icon: Icon(
                Icons.skip_previous_rounded,
                size: 28,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: _controller.skipToPrevious,
            ),

            // Play/Pause Button
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: SvgPicture.asset(
                  _controller.isPlaying.value
                      ? Images.Pause_Icon
                      : Images.Play_Icon,
                  color: Colors.white,
                  width: 24,
                  height: 24,
                ),
                onPressed: _controller.togglePlayPause,
              ),
            ),

            // Next Button
            IconButton(
              icon: Icon(
                Icons.skip_next_rounded,
                size: 28,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: _controller.skipToNext,
            ),
          ],
        ),
      );
    });
  }
}
