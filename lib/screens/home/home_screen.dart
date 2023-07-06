// ignore_for_file: unnecessary_null_comparison

import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/auth_controller.dart';
import '../../music_player/music_handler.dart';
import 'other_artist_screen.dart';

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

//   String mostPlayedGenre = '';

//  @override
// void initState() {
//   super.initState();
//   fetchMostPlayedGenre();
// }

// Future<void> fetchMostPlayedGenre() async {
//   final List<SongModel> listenedSongs =
//       await _listenCon.getListeningHistory();
//   final Map<String, int> genreCountMap = {};

//   for (final song in listenedSongs) {
//     final genre = song.genre;
//     genreCountMap[genre] = (genreCountMap[genre] ?? 0) + 1;
//   }

//   String newMostPlayedGenre = '';
//   int maxCount = 0;

//   genreCountMap.forEach((genre, count) {
//     if (count > maxCount) {
//       maxCount = count;
//       newMostPlayedGenre = genre;
//     }
//   });

//   if (mounted) {
//     setState(() {
//       mostPlayedGenre = newMostPlayedGenre;
//     });
//   }
// }

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
            pinoyPride(),
            newReleases(),
            newPlaylist(),
            editorsPlaylists(),
            suggestedUsers(),
            popularTracks(),
            basedOnLikedSongs(),
            artiststToLookOut(),
            // recentListeningMostPlayedGenre(),
            recentListening(),
            recommendedPlaylistsGenre(),
            basedOnListeningHistory(),
            basedOnListeningHistoryLanguage(),
            basedOnListeningHistoryMoods(),

            suggestedSongFromFollower(),
            const SizedBox(height: 120),
          ]),
        ),
      ),
    );
  }

  StreamBuilder<List<PlaylistModel>> newPlaylist() {
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

          playlists.sort((a, b) => b.createdAt.compareTo(a
              .createdAt)); // Sort playlists in descending order based on creation date

          playlists = playlists.take(5).toList();

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
              caption: 'Newly posted playlist',
            );
          }
        }
      },
    );
  }

  StreamBuilder<List<PlaylistModel>> pinoyPride() {
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
                  playlist.isOfficial != null &&
                  playlist.isOfficial == true &&
                  playlist.genre == 'Random')
              .toList();

          playlists = playlists.take(5).toList();

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
              caption: 'Pinoy Pride 🔥',
            );
          }
        }
      },
    );
  }

  StreamBuilder<List<UserModel>?> suggestedUsers() {
    return StreamBuilder<List<UserModel>?>(
      stream: UserModel.getNonFollowers(FirebaseAuth.instance.currentUser!.uid)
          .asStream(),
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
              .where((user) =>
                  user.accountType != 'Admin' &&
                  user.uid != FirebaseAuth.instance.currentUser!.uid)
              .toList();

          users = users.take(5).toList();

          users.shuffle(random);
          return users.isEmpty
              ? const SizedBox.shrink()
              : ArtistDisplay(users: users, caption: 'Suggested Users');
        }
      },
    );
  }

  // StreamBuilder<List<PlaylistModel>> recentListeningMostPlayedGenre() {
  //   return StreamBuilder<List<PlaylistModel>>(
  //     stream: _playCon.getPlaylistStream(),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData || snapshot.data == null) {
  //         return const LoadingContainer();
  //       }
  //       if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       }

  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const LoadingContainer();
  //       } else {
  //         List<PlaylistModel> playlists = snapshot.data!;

  //         playlists = playlists
  //             .where((playlist) =>
  //                 playlist.isOfficial == true &&
  //                 playlist.genre == mostPlayedGenre)
  //             .toList();

  //         if (playlists.isEmpty) {
  //           return const SizedBox.shrink();
  //         } else {
  //            playlists.shuffle();

  //           return PlaylistDisplay(
  //             playlists: playlists,
  //             onTap: (playlist) {
  //               Navigator.of(context).push(
  //                 MaterialPageRoute(
  //                   builder: (context) =>
  //                       PlaylistDetailScreen(playlist: playlist),
  //                 ),
  //               );
  //             },
  //             caption: mostPlayedGenre,
  //          );
  //         }
  //       }
  //      }
  //   );
  // }

  StreamBuilder<List<SongModel>> basedOnListeningHistoryMoods() {
    return StreamBuilder<List<SongModel>>(
      stream: _listenCon.getRecommendedSongsBasedOnMoods().asStream(),
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
              .where(
                  (song) => song.uid != FirebaseAuth.instance.currentUser!.uid)
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
                  caption: 'Recommended based on moods',
                );
        }
      },
    );
  }

  StreamBuilder<List<SongModel>> basedOnListeningHistoryLanguage() {
    return StreamBuilder<List<SongModel>>(
      stream: _listenCon.getRecommendedSongsBasedOnLanguage().asStream(),
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
              .where(
                  (song) => song.uid != FirebaseAuth.instance.currentUser!.uid)
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
                  caption: 'Recommended based on language',
                );
        }
      },
    );
  }

  StreamBuilder<List<PlaylistModel>> recommendedPlaylistsGenre() {
    return StreamBuilder<List<PlaylistModel>>(
        stream: _listenCon.getRecommendedPlaylistBasedOnGenre().asStream(),
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
                caption: 'Playlist recommendation',
              );
            }
          }
        });
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

          playlists = playlists.take(5).toList();

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
              caption: 'Editor\'s Playlists',
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
                  caption: 'Recently played songs',
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
              .where(
                  (song) => song.uid != FirebaseAuth.instance.currentUser!.uid)
              .toList();

          if (songs.length <= 3) {
            return const SizedBox.shrink();
          } else {
            return SongDisplay(
              songs: songs,
              onTap: (song) {
                widget.musicHandler.currentSongs = songs;
                widget.musicHandler.currentIndex = songs.indexOf(song);
                widget.musicHandler.setAudioSource(
                    songs[widget.musicHandler.currentIndex], uid);
              },
              caption: 'More on what you like..',
            );
          }
        }
      },
    );
  }

  StreamBuilder<List<SongModel>> basedOnListeningHistory() {
    return StreamBuilder<List<SongModel>>(
      stream: _listenCon.getRecommendedSongsBasedOnGenre().asStream(),
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
              .where(
                  (song) => song.uid != FirebaseAuth.instance.currentUser!.uid)
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
                  caption: 'Recommended based on genre',
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
              : ArtistDisplay(users: users, caption: 'Artists to look out for');
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
                    caption: 'What\'s new?',
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
                    caption: 'Home for OPM',
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
                  caption: 'Popular Tracks',
                );
        }
      },
    );
  }

//suggested follower
  StreamBuilder<DocumentSnapshot<Object?>> suggestedSongFromFollower() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        // User document exists, retrieve follower array
        List<dynamic> followerIDs =
            (snapshot.data!.data() as Map<String, dynamic>)['followings'] ?? [];

        if (snapshot.hasData) {
          // Retrieve songs with matching UID to follower IDs
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('songs').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              if (snapshot.hasData) {
                List<SongModel> songsData = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return SongModel(
                    songId: data['song_id'] as String,
                    title: data['title'] as String,
                    artist: data['artist'] as String,
                    fileName: data['file_name'] as String,
                    audio: data['audio'] as String,
                    albumCover: data['album_cover'] as String,
                    createdAt: (data['created_at'] as Timestamp).toDate(),
                    writers:
                        List<String>.from(data['writers'] as List<dynamic>),
                    producers:
                        List<String>.from(data['producers'] as List<dynamic>),
                    genre: data['genre'] as String,
                    uid: data['uid'] as String,
                    languages:
                        List<String>.from(data['languages'] as List<dynamic>),
                    description:
                        List<String>.from(data['description'] as List<dynamic>),
                    playCount: data['playCount'] as int? ?? 0,
                    likeCount: data['likeCount'] as int? ?? 0,
                  );
                }).toList();

                // Filter songs by follower IDs
                List<SongModel> followerSongs = songsData
                    .where((song) => followerIDs.contains(song.uid))
                    .toList();

                // Sort follower songs by play count in descending order
                followerSongs
                    .sort((a, b) => b.playCount.compareTo(a.playCount));

                // Take the top 5 songs (limited to one song per user)
                List<SongModel> topSongs = [];
                List<String> addedUserIDs = [];
                for (SongModel song in followerSongs) {
                  if (!addedUserIDs.contains(song.uid)) {
                    topSongs.add(song);
                    addedUserIDs.add(song.uid);
                  }
                  if (topSongs.length >= 5) {
                    break;
                  }
                }

                return topSongs.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 25, bottom: 10),
                                child: buildCustomContainer(
                                    'Suggested song for you...')),
                          ),
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: topSongs.map((user) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25, top: 10),
                                    child: Column(
                                      children: [
                                        Column(children: [
                                          InkWell(
                                            onTap: () {
                                              int index = topSongs.indexWhere(
                                                  (song) =>
                                                      song.songId ==
                                                      user.songId);

                                              final selectedSong =
                                                  topSongs[index];

                                              if (selectedSong != null) {
                                                widget.musicHandler
                                                    .currentSongs = topSongs;
                                                widget.musicHandler
                                                        .currentIndex =
                                                    topSongs
                                                        .indexOf(selectedSong);
                                                widget.musicHandler
                                                    .setAudioSource(
                                                        selectedSong, uid!);
                                              }
                                            },
                                            onLongPress: () {
                                              int index = topSongs.indexWhere(
                                                  (song) =>
                                                      song.songId ==
                                                      user.songId);

                                              showModalBottomSheet(
                                                  backgroundColor:
                                                      musikatColor4,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return SingleChildScrollView(
                                                      child: SongBottomField(
                                                        song: songsData[index],
                                                        hideEdit: true,
                                                        hideDelete: true,
                                                        hideRemoveToPlaylist:
                                                            true,
                                                        hideLike: null,
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: user.albumCover.isNotEmpty
                                                ? Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          spreadRadius: 2,
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      image: user.albumCover
                                                              .isNotEmpty
                                                          ? DecorationImage(
                                                              image: CachedNetworkImageProvider(
                                                                  user.albumCover),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : null,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width: 120,
                                                    height: 120,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          musikatColor4,
                                                      maxRadius: 30,
                                                      child: Text(
                                                        user.title.isNotEmpty
                                                            ? user.title[0]
                                                                .toUpperCase()
                                                            : '',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 30),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 5),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              user.title,
                                              style: titleStyle,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              user.artist,
                                              style: titleStyle,
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
//end sugggested follower

  Container buildCustomContainer(String text) {
    return Container(
      padding: const EdgeInsets.only(top: 25),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: sloganStyle,
      ),
    );
  }
}
