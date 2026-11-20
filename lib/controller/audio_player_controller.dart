import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/data/model/response/reciters_model.dart';
import 'package:nazar_e_alam/data/model/response/reciter_surahs_model.dart';
import 'package:nazar_e_alam/helper/audio_handler.dart';
import 'package:nazar_e_alam/helper/audio_service_helper.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class AudioPlayerController extends GetxController {
  final ApiClient apiClient;

  AudioPlayerController({required this.apiClient});

  // --------------------------------------------------
  // RECITERS
  // --------------------------------------------------

  final RxBool isRecitersLoading = false.obs;

  RecitersModel? recitersListApiData;

  Future<void> fetchReciterData() async {
    try {
      isRecitersLoading(true);

      final response = await apiClient.getData(Endpoints.RECITERS);

      if (response.statusCode == 200) {
        recitersListApiData = RecitersModel.fromJson(
          Map<String, dynamic>.from(response.body),
        );

        if (kDebugMode) {
          print('Reciters List: ${recitersListApiData?.data?.length ?? 0}');
        }
      } else {
        if (kDebugMode) {
          print('Reciter API error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reciters: $e');
      }
    } finally {
      isRecitersLoading(false);
      update();
    }
  }

  // --------------------------------------------------
  // RECITER SURAHS
  // --------------------------------------------------

  final RxBool isAudioLoading = false.obs;

  ReciterSurahsModel? reciterSurahsApiData;

  Future<void> fetchSurahs(String slug) async {
    try {
      isAudioLoading(true);

      final endpoint = Endpoints.AUDIO_SURHAS.replaceFirst(
        '{slug}',
        Uri.encodeComponent(slug),
      );

      final response = await apiClient.getData(endpoint);

      if (response.statusCode == 200) {
        reciterSurahsApiData = ReciterSurahsModel.fromJson(
          Map<String, dynamic>.from(response.body),
        );

        if (kDebugMode) {
          print('Surahs loaded: ${reciterSurahsApiData?.surahs?.length ?? 0}');
          print('Reciter: ${reciterSurahsApiData?.reciter?.name}');
          print('Host: ${reciterSurahsApiData?.host}');
        }
      } else {
        if (kDebugMode) {
          print('Surah API error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching surahs: $e');
      }
    } finally {
      isAudioLoading(false);
      update();
    }
  }

  // --------------------------------------------------
  // AUDIO PLAYER
  // --------------------------------------------------

  final AudioHandler _audioHandler = AudioServiceHelper.audioHandler;

  AudioPlayerHandler get _handler {
    if (_audioHandler is AudioPlayerHandler) {
      return _audioHandler;
    }

    throw Exception('AudioHandler is not an instance of AudioPlayerHandler');
  }

  final RxList<MediaItem> audioList = <MediaItem>[].obs;

  final Rx<MediaItem?> currentMediaItem = Rx<MediaItem?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isPlaying = false.obs;

  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  StreamSubscription<MediaItem?>? _mediaItemSubscription;
  StreamSubscription<PlaybackState>? _playbackSubscription;

  @override
  void onInit() {
    super.onInit();

    // Listen only once for the lifetime of this controller.
    _mediaItemSubscription = _audioHandler.mediaItem.listen((item) {
      currentMediaItem.value = item;
      duration.value = item?.duration ?? Duration.zero;
      update();
    });

    _playbackSubscription = _audioHandler.playbackState.listen((state) {
      isPlaying.value = state.playing;
      position.value = state.updatePosition;

      if (state.processingState == AudioProcessingState.completed) {
        position.value = duration.value;
      }

      update();
    });
  }

  // --------------------------------------------------
  // LOAD SELECTED SURAH
  // --------------------------------------------------

  Future<void> loadSurahAudio(String slug, Surah surah) async {
    try {
      isLoading(true);
      audioList.clear();

      final apiData = reciterSurahsApiData;

      if (apiData == null || apiData.host == null || apiData.host!.isEmpty) {
        throw Exception('Surah data not loaded. Call fetchSurahs() first.');
      }

      final host = apiData.host!.replaceFirst(RegExp(r'/+$'), '');

      final reciter = apiData.reciter;

      final reciterName = reciter?.name ?? 'Unknown Reciter';
      final reciterPicture = reciter?.profilePicture ?? '';

      final selectedSurahNumber = surah.number ?? 0;

      final allSurahs = apiData.surahs ?? [];

      if (selectedSurahNumber <= 0 || allSurahs.isEmpty) {
        throw Exception('Invalid surah data.');
      }

      final List<MediaItem> items = [];

      // Start from selected Surah and continue until the last Surah.
      final remainingSurahs =
          allSurahs
              .where((item) => (item.number ?? 0) >= selectedSurahNumber)
              .toList()
            ..sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));

      for (final currentSurah in remainingSurahs) {
        final surahNumber = currentSurah.number ?? 0;
        final versesCount = currentSurah.versesCount ?? 0;

        if (surahNumber <= 0 || versesCount <= 0) {
          continue;
        }

        for (int ayahNumber = 1; ayahNumber <= versesCount; ayahNumber++) {
          final surahCode = surahNumber.toString().padLeft(3, '0');
          final ayahCode = ayahNumber.toString().padLeft(3, '0');

          final fileName = '$surahCode$ayahCode.mp3';

          final audioUrl = '$host/reciters/$slug/ayahs/$fileName';

          items.add(
            MediaItem(
              id: audioUrl,
              album: currentSurah.arabicName ?? 'Surah $surahNumber',
              title: 'Ayah $ayahNumber',
              artist: reciterName,
              artUri: reciterPicture.isNotEmpty
                  ? Uri.tryParse(reciterPicture)
                  : null,
              extras: {
                'surah_number': surahNumber,
                'ayah_number': ayahNumber,
                'reciter_slug': slug,
              },
            ),
          );
        }
      }

      if (items.isEmpty) {
        throw Exception('No audio items generated.');
      }

      audioList.assignAll(items);

      await _handler.loadPlaylist(items);

      currentMediaItem.value = audioList.first;
      position.value = Duration.zero;
      duration.value = Duration.zero;

      if (kDebugMode) {
        print('Total audio items: ${items.length}');
        print('Starting Surah: $selectedSurahNumber');
        print('First audio: ${items.first.id}');
        print('Last audio: ${items.last.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading continuous audio: $e');
      }
    } finally {
      isLoading(false);
      update();
    }
  }
  // --------------------------------------------------
  // PLAYBACK CONTROLS
  // --------------------------------------------------

  Future<void> playMediaItem(MediaItem mediaItem) async {
    try {
      await _audioHandler.playMediaItem(mediaItem);
    } catch (e) {
      if (kDebugMode) {
        print('Play media item error: $e');
      }
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (isPlaying.value) {
        await _audioHandler.pause();
      } else {
        await _audioHandler.play();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Play/pause error: $e');
      }
    }
  }

  Future<void> skipToNext() async {
    await _audioHandler.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await _audioHandler.skipToPrevious();
  }

  Future<void> seekToPosition(double value) async {
    if (value >= 0 && value <= duration.value.inMilliseconds) {
      await _audioHandler.seek(Duration(milliseconds: value.toInt()));
    }
  }

  @override
  void onClose() {
    _mediaItemSubscription?.cancel();
    _playbackSubscription?.cancel();

    super.onClose();
  }
}
