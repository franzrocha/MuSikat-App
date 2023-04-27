import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mycompany.myapp.audio',
        androidNotificationChannelName: 'Audio Service Demo',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/musikat_launcher'),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final player = AudioPlayer();
  late List<SongModel> songs;

  int currentIndex = 0;
  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));
    await player.play();
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.pause],
    ));
    await player.pause();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  Future<void> setAudio() async {
    player.setLoopMode(LoopMode.off);
    final source = AudioSource.uri(
      Uri.parse(songs[currentIndex].audio),
      tag: MediaItem(
        id: songs[currentIndex].songId,
        title: songs[currentIndex].title,
        artist: songs[currentIndex].artist,
        artUri: Uri.parse(songs[currentIndex].albumCover),
      ),
    );

    try {
      await player.setAudioSource(source);
      await player.play();
    } catch (e) {
      if (e is PlatformException) {
        await Future.delayed(const Duration(seconds: 2));
        await setAudio();
      } else {
        rethrow;
      }
    }
  }

  void notifyAudioHandlerAboutPlaybackEvents() {
    player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[player.processingState]!,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void listenForDurationChanges() {
    player.durationStream.listen((duration) {
      final index = player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }
}
