import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/service_locators.dart';

class MusicHandler with ChangeNotifier, RouteAware {
  final AudioPlayer player = AudioPlayer();
  final SongsController _songCon = SongsController();
  //final MusicHandler _musicHandler = locator<MusicHandler>();

  //list of songs declared
  List<SongModel> currentSongs = [];

  List<SongModel> genreSongs = [];
  List<SongModel> descriptionSongs = [];
  List<SongModel> latestSong = [];
  List<SongModel> languageSongs = [];
  List<SongModel> songSearchResult = [];
  List<SongModel> likedSongs = [];

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  int currentIndex = 0;
  SongModel? currentSong;

  MediaItem _createMediaItem(SongModel song) => MediaItem(
        id: song.songId,
        title: song.title,
        artist: song.artist,
        artUri: Uri.parse(song.albumCover),
      );

  Future<void> setAudioSource(SongModel song, String uid) async {
    final source = AudioSource.uri(
      Uri.parse(song.audio),
      tag: _createMediaItem(song),
    );
    try {
      if (!isPlaying ||
          (currentSong != null && currentSong?.songId != song.songId)) {
        await player.setAudioSource(source);
        isPlaying = true;
        currentSong = song;
      }
      await player.play();
      notifyListeners();
      await _songCon.updateSongPlayCount(song.songId);
    } catch (e) {
      if (e is PlatformException) {
        await Future.delayed(const Duration(seconds: 5));
        await setAudioSource(song, uid);
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

    return [if (duration.inHours > 0) hours, minutes, seconds].join(":");
  }

  // Getters
  bool get getIsPlaying => isPlaying;
  Duration get getDuration => duration;
  Duration get getPosition => position;

  // @override
  // void dispose() {
  //   player.dispose();
  //   super.dispose();
  // }

  @override
  void didPush() {
    player.play();
    isPlaying = true;
    notifyListeners();
  }

  @override
  void didPopNext() {
    player.play();
    isPlaying = true;
    notifyListeners();
  }

  @override
  void didPop() {
    player.pause();
    isPlaying = false;
    notifyListeners();
  }

  @override
  void didPushNext() {
    player.pause();
    isPlaying = false;
    notifyListeners();
  }
}
