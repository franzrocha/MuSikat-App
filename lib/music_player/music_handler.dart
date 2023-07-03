import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:musikat_app/controllers/listening_history_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/listening_history_model.dart';
import 'package:musikat_app/models/song_model.dart';

import '../controllers/liked_songs_controller.dart';

class MusicHandler with ChangeNotifier, RouteAware {
  final AudioPlayer player = AudioPlayer();
  final SongsController _songCon = SongsController();
  final LikedSongsController likedCon = LikedSongsController();
  final ListeningHistoryController _listenCon = ListeningHistoryController();

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

  ListeningHistoryModel? recentlyPlayed;

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  bool isLoadingAudio = false;
  bool isLiked = false;
  bool isLoading = false;
  bool isPlayingNext = false;

  int currentIndex = 0;
  SongModel? currentSong;

  MediaItem _createMediaItem(SongModel song) => MediaItem(
        id: song.songId,
        title: song.title,
        artist: song.artist,
        artUri: Uri.parse(song.albumCover),
      );

  Future<void> setAudioSource(SongModel song, String uid) async {
    try {
      final source = AudioSource.uri(
        Uri.parse(song.audio),
        tag: _createMediaItem(song),
      );
      print(
          "Current Song: ${currentSong?.title ?? 'None'} New Song: ${song.title}");

      if (currentSong == null ||
          (currentSong != null && currentSong?.songId != song.songId)) {
        isPlaying = true;
        currentSong = song;
        await player.setAudioSource(source);
        notifyListeners();
        await player.play();
      } else {
        await player.play();
      }

      String currentUser = FirebaseAuth.instance.currentUser!.uid;
      await _songCon.updateSongPlayCount(song.songId);

      await _listenCon.addListeningHistorySong(currentUser, song.songId);

      notifyListeners();
    } catch (e) {
      if (e is PlatformException) {
        await Future.delayed(const Duration(seconds: 5));
        await setAudioSource(song, uid);
      } else {
        await player.play();
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

  Future<void> playPrevious() async {
    if (isLoadingAudio) {
      return;
    }
    if (currentIndex > 0) {
      currentIndex--;
    } else {
      currentIndex = currentSongs.length - 1;
    }
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    try {
      checkIfSongIsLiked();
      await setAudioSource(currentSongs[currentIndex], currentUser);
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await setAudioSource(currentSongs[currentIndex], currentUser);
    }
  }

  Future<void> playNext() async {
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    try {
      isPlayingNext = true;
      if (isLoadingAudio) {
        return;
      }
      if (currentIndex < currentSongs.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }

      checkIfSongIsLiked();
      await setAudioSource(currentSongs[currentIndex], currentUser);
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await setAudioSource(currentSongs[currentIndex], currentUser);
    } finally {
      isPlayingNext = false;
      notifyListeners();
    }
  }

  void checkIfSongIsLiked() async {
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    isLiked = await likedCon.isSongLikedByUser(
        currentSongs[currentIndex].songId, currentUser);
    notifyListeners();
  }

  void setIsLiked(bool isLiked) {
    this.isLiked = isLiked;
    notifyListeners();
  }

  void initSongStream() {
    player.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      final playing = playerState.playing;

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        isLoading = true;
      } else if (playing != true) {
        isLoading = false;
        isPlaying = false;
      } else if (processingState != ProcessingState.completed) {
        isLoading = false;
        isPlaying = true;
      } else if (processingState == ProcessingState.completed) {
        isLoading = true;
        if (!isPlayingNext) {
          playNext();
        }
      } else {
        isPlaying = false;
      }
      notifyListeners();
    });
  }

  void setIsPlaying(bool isPlaying) {
    this.isPlaying = isPlaying;
    notifyListeners();
  }

  // Getters
  bool get getIsPlaying => isPlaying;
  Duration get getDuration => duration;
  Duration get getPosition => position;

  // void addToQueue(SongModel song) {
  //   currentSongs.add(song);
  //   if (currentSong == null) {
  //     currentIndex = 0;
  //     currentSong = song;
  //   }
  //   notifyListeners();
  // }
}
// @override
  // void dispose() {
  //   player.dispose();
  //   super.dispose();
  // }