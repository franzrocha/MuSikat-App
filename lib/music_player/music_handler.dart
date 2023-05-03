import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:musikat_app/models/song_model.dart';

class MusicHandler with ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentIndex = 0;
  List<SongModel> songs = [];

  MediaItem _createMediaItem(SongModel song) {
    return MediaItem(
      id: song.songId,
      title: song.title,
      artist: song.artist,
      artUri: Uri.parse(song.albumCover),
    );
  }

  Future<void> setAudioSource(AudioPlayer player, SongModel song) async {
    final source = AudioSource.uri(
      Uri.parse(song.audio),
      tag: _createMediaItem(song),
    );

    try {
      await player.setAudioSource(source);
      await player.play();
      isPlaying = true;
      notifyListeners();
    } catch (e) {
      if (e is PlatformException) {
        await Future.delayed(const Duration(seconds: 5));
        await setAudioSource(player, song);
      } else {
        rethrow;
      }
    }
  }

  String time(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(":");
  }

  //getter
  bool get getIsPlaying => isPlaying;
  Duration get getDuration => duration;
  Duration get getPosition => position;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
