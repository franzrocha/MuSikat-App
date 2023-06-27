// ignore_for_file: unnecessary_null_comparison

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/listening_history_controller.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/models/liked_songs_model.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/profile/playlist_detail_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/widgets/display_widgets.dart';
import '../../music_player/music_handler.dart';

class HomeScreen extends StatefulWidget {
  final MusicHandler musicHandler;
  static const String route = 'home-screen';

  const HomeScreen({
    Key? key,
    required this.musicHandler,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SongsController _songCon = SongsController();
  final PlaylistController _playCon = PlaylistController();
  final ListeningHistoryController _listenCon = ListeningHistoryController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SingleChildScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 5),
            homeForOPM(),
            editorsPlaylists(),
            newReleases(),
            popularTracks(),
            artiststToLookOut(),
            recentListening(),
            basedOnLikedSongs(),
            basedOnListeningHistory(),
            const SizedBox(height: 120),
          ]),
        ),
      ),
    );
  }

  StreamBuilder<List<PlaylistModel>> editorsPlaylists() {
    return StreamBuilder<List<PlaylistModel>>(
      stream: _playCon.getPlaylistStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoadingContainer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingContainer();
        } else {
          List<PlaylistModel> playlists = snapshot.data!;

          playlists = playlists
              .where((playlist) =>
                  playlist.isOfficial != null && playlist.isOfficial == true)
              .toList();

          playlists.take(5);

          if (playlists.isEmpty) {
            return const SizedBox.shrink();
          } else {
            playlists.shuffle();

            return PlaylistDisplay(
              playlists: playlists,
              onTap: (playlist) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        PlaylistDetailScreen(playlist: playlist),
                  ),
                );
              },
              slogan: 'Editor\'s Playlists',
            );
          }
        }
      },
    );
  }

  FutureBuilder<List<SongModel>> recentListening() {
    return FutureBuilder<List<SongModel>>(
      future: _listenCon.getListeningHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoadingContainer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingContainer();
        } else {
          List<SongModel> songs = snapshot.data!;

          songs = songs.take(5).toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: songs,
                  onTap: (song) {
                    widget.musicHandler.currentSongs = songs;
                    widget.musicHandler.currentIndex = songs.indexOf(song);
                    widget.musicHandler.setAudioSource(
                        songs[widget.musicHandler.currentIndex], uid);
                  },
                  slogan: 'Recently played songs',
                );
        }
      },
    );
  }

  StreamBuilder<List<SongModel>> basedOnLikedSongs() {
    return StreamBuilder<List<SongModel>>(
      stream: LikedSongsModel.getRecommendedSongsByLike().asStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoadingContainer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingContainer();
        } else {
          List<SongModel> songs = snapshot.data!;

          songs = songs
              .where((song) =>
                  song.songId != FirebaseAuth.instance.currentUser!.uid)
              .toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: songs,
                  onTap: (song) {
                    widget.musicHandler.currentSongs = songs;
                    widget.musicHandler.currentIndex = songs.indexOf(song);
                    widget.musicHandler.setAudioSource(
                        songs[widget.musicHandler.currentIndex], uid);
                  },
                  slogan: 'Based on your liked songs',
                );
        }
      },
    );
  }

  StreamBuilder<List<SongModel>> basedOnListeningHistory() {
    return StreamBuilder<List<SongModel>>(
      stream: _listenCon.getRecommendedSongs().asStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoadingContainer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingContainer();
        } else {
          List<SongModel> songs = snapshot.data!;

          songs = songs
              .where((song) =>
                  song.songId != FirebaseAuth.instance.currentUser!.uid)
              .toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: songs,
                  onTap: (song) {
                    widget.musicHandler.currentSongs = songs;
                    widget.musicHandler.currentIndex = songs.indexOf(song);
                    widget.musicHandler.setAudioSource(
                        songs[widget.musicHandler.currentIndex], uid);
                  },
                  slogan: 'Recommended based on genre',
                );
        }
      },
    );
  }

  StreamBuilder<List<UserModel>?> artiststToLookOut() {
    return StreamBuilder<List<UserModel>?>(
      stream: _songCon.getUsersWithSongs().asStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoadingCircularContainer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingCircularContainer();
        } else {
          List<UserModel> users = snapshot.data!;
          Random random = Random(DateTime.now().minute);

          users = users
              .where(
                  (user) => user.uid != FirebaseAuth.instance.currentUser!.uid)
              .toList();
          users.shuffle(random);

          users = users.take(5).toList();

          return users.isEmpty
              ? const SizedBox.shrink()
              : ArtistDisplay(users: users, slogan: 'Artists to look out for');
        }
      },
    );
  }

  StreamBuilder<List<SongModel>> newReleases() {
    return StreamBuilder<List<SongModel>>(
        stream: _songCon.getSongsStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<SongModel>> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const LoadingContainer();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingContainer();
          } else {
            final songs = snapshot.data!;
            final filteredSongs =
                songs.where((song) => song.createdAt != null).toList();
            final limitedSongs = filteredSongs.take(5).toList();
            widget.musicHandler.latestSong = filteredSongs;

            limitedSongs.shuffle(Random(DateTime.now().minute));
            return songs.isEmpty
                ? const SizedBox.shrink()
                : SongDisplay(
                    songs: limitedSongs,
                    onTap: (song) {
                      widget.musicHandler.currentSongs = limitedSongs;
                      widget.musicHandler.currentIndex =
                          limitedSongs.indexOf(song);
                      widget.musicHandler.setAudioSource(
                          limitedSongs[widget.musicHandler.currentIndex], uid);
                    },
                    slogan: 'What\'s new?',
                  );
          }
        });
  }

  StreamBuilder<List<SongModel>> homeForOPM() {
    return StreamBuilder<List<SongModel>>(
        stream: _songCon.getSongsStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<SongModel>> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const LoadingContainer();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingContainer();
          } else {
            Random random = Random(DateTime.now().minute);

            final songs = snapshot.data!;
            final randomSongs = songs..shuffle(random);
            final limitedSongs = randomSongs.take(5).toList();

            widget.musicHandler.randomSongs = limitedSongs;

            return songs.isEmpty
                ? const SizedBox.shrink()
                : SongDisplay(
                    songs: limitedSongs,
                    onTap: (song) {
                      widget.musicHandler.currentSongs = limitedSongs;
                      widget.musicHandler.currentIndex =
                          limitedSongs.indexOf(song);
                      widget.musicHandler.setAudioSource(
                          limitedSongs[widget.musicHandler.currentIndex], uid);
                    },
                    slogan: 'Home for OPM',
                  );
          }
        });
  }

  StreamBuilder<List<SongModel>> popularTracks() {
    return StreamBuilder<List<SongModel>>(
      stream: _songCon.getSongsStream(),
      builder: (BuildContext context, AsyncSnapshot<List<SongModel>> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoadingContainer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingContainer();
        } else {
          final songs = snapshot.data!;

          songs.sort((a, b) => b.playCount.compareTo(a.playCount));
          final topSongs = songs.sublist(0, 5);
          final random = Random(DateTime.now().minute);
          topSongs.shuffle(random);

          widget.musicHandler.randomSongs = topSongs;
          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: topSongs,
                  onTap: (song) {
                    widget.musicHandler.currentSongs = topSongs;
                    widget.musicHandler.currentIndex = topSongs.indexOf(song);
                    widget.musicHandler.setAudioSource(
                        topSongs[widget.musicHandler.currentIndex], uid);
                  },
                  slogan: 'Popular Tracks',
                );
        }
      },
    );
  }
}
