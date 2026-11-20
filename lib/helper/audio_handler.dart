// ignore_for_file: deprecated_member_use

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  late ConcatenatingAudioSource _playlist;
  final List<MediaItem> _mediaItems = [];

  AudioPlayerHandler() {
    _initializePlayer();
  }

  void _initializePlayer() {
    _playlist = ConcatenatingAudioSource(
      children: [],
      useLazyPreparation: true,
    );

    _player.playbackEventStream.listen(
      (event) {
        playbackState.add(_transformEvent(event));
      },
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          print('Playback stream error: $error');
        }
      },
    );

    // Register this listener only once.
    _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _mediaItems.length) {
        mediaItem.add(_mediaItems[index]);
      }
    });

    // Update the currently playing item's duration.
    _player.durationStream.listen((newDuration) {
      if (newDuration == null) return;

      final index = _player.currentIndex;

      if (index != null && index >= 0 && index < _mediaItems.length) {
        final updatedItem = _mediaItems[index].copyWith(duration: newDuration);

        _mediaItems[index] = updatedItem;
        mediaItem.add(updatedItem);
        queue.add(List<MediaItem>.from(_mediaItems));
      }
    });
  }

  // Load a surah's ayah playlist.
  Future<void> loadPlaylist(List<MediaItem> items) async {
    try {
      await _player.stop();

      _mediaItems
        ..clear()
        ..addAll(items);

      queue.add(List<MediaItem>.from(_mediaItems));

      if (_mediaItems.isEmpty) {
        mediaItem.add(null);
        return;
      }

      final sources = _mediaItems.map((item) {
        return AudioSource.uri(Uri.parse(item.id));
      }).toList();

      _playlist = ConcatenatingAudioSource(
        children: sources,
        useLazyPreparation: true,
      );

      await _player.setAudioSource(_playlist, initialIndex: 0, preload: true);

      mediaItem.add(_mediaItems[0]);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading playlist: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    final index = _mediaItems.indexWhere((item) => item.id == mediaItem.id);

    if (index != -1) {
      await _player.seek(Duration.zero, index: index);
      await play();
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> stop() async {
    await _player.stop();

    _mediaItems.clear();
    mediaItem.add(null);
    queue.add([]);

    playbackState.add(
      playbackState.value.copyWith(
        controls: [],
        systemActions: {},
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );

    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
