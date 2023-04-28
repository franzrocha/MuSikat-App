import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musikat_app/models/song_model.dart';

class MusicPlayerController with ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentIndex = 0;
  List<SongModel> songs = [];

  MusicPlayerController() {
    player = AudioPlayer();
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
  int get getCurrentIndex => currentIndex;
}
