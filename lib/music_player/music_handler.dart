import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/service_locators.dart';

import '../controllers/liked_songs_controller.dart';

class MusicHandler with ChangeNotifier, RouteAware {
  final AudioPlayer player = AudioPlayer();
  final SongsController _songCon = SongsController();
  final LikedSongsController likedCon = LikedSongsController();
  //final MusicHandler _musicHandler = locator<MusicHandler>();

  //list of songs declared
  List<SongModel> currentSongs = [];

  List<SongModel> genreSongs = [];
  List<SongModel> descriptionSongs = [];
  List<SongModel> latestSong = [];
  List<SongModel> languageSongs = [];
  List<SongModel> songSearchResult = [];
  List<SongModel> likedSongs = [];
  List<SongModel> randomSongs = [];

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isLoadingAudio = false;
  bool isLiked = false;

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

  Future<void> playPrevious(String uid, List<SongModel> songs) async {
    if (isLoadingAudio) {
      return;
    }
    if (currentIndex > 0) {
      currentIndex--;
    } else {
      currentIndex = currentSongs.length - 1;
    }

    try {
      checkIfSongIsLiked(uid, songs);
      await setAudioSource(currentSongs[currentIndex], uid);
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await setAudioSource(currentSongs[currentIndex], uid);
    }
  }

  Future<void> playNext(String uid, List<SongModel> songs) async {
    if (isLoadingAudio) {
      return;
    }
    if (currentIndex < currentSongs.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }

    try {
      checkIfSongIsLiked(uid, songs);
      await setAudioSource(currentSongs[currentIndex], uid);
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await setAudioSource(currentSongs[currentIndex], uid);
    }
  }

  void checkIfSongIsLiked(String uid, List<SongModel> songs) async {
    isLiked = await likedCon.isSongLikedByUser(songs[currentIndex].songId, uid);
    notifyListeners();
  }

  void setIsLiked(bool isLiked) {
    this.isLiked = isLiked;
    notifyListeners();
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
