import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/playlist_model.dart';
import '../../../models/song_model.dart';
import '../../../models/user_model.dart';
import '../../../music_player/music_handler.dart';
import '../../../utils/constants.dart';
import '../../../widgets/display_widgets.dart';
import '../../../widgets/loading_widgets.dart';
import '../../../widgets/song_bottom_field.dart';
import '../profile/playlist_detail_screen.dart';

class NewlyAddedPlaylistStreamBuilder extends StatelessWidget {
  final Stream<List<PlaylistModel>> playlistStream;
  final String caption;

  NewlyAddedPlaylistStreamBuilder(
      {required this.playlistStream, required this.caption});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlaylistModel>>(
      stream: playlistStream,
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

          playlists.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
              caption: caption,
            );
          }
        }
      },
    );
  }
}

class PinoyPrideStreamBuilder extends StatelessWidget {
  final Stream<List<PlaylistModel>> playlistStream;
  final String genreFilter;
  final String caption;

  PinoyPrideStreamBuilder({
    required this.playlistStream,
    required this.genreFilter,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlaylistModel>>(
      stream: playlistStream,
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
                  playlist.genre == genreFilter)
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
              caption: caption,
            );
          }
        }
      },
    );
  }
}

class SuggestedUsersStreamBuilder extends StatelessWidget {
  final Stream<List<UserModel>?> userStream;
  final String currentUserUid;
  final String caption;

  SuggestedUsersStreamBuilder({
    required this.userStream,
    required this.currentUserUid,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>?>(
      stream: userStream,
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
                  user.accountType != 'Admin' && user.uid != currentUserUid)
              .toList();

          users = users.take(5).toList();

          users.shuffle(random);
          return users.isEmpty
              ? const SizedBox.shrink()
              : ArtistDisplay(users: users, caption: caption);
        }
      },
    );
  }
}

class BasedOnListeningHistoryMoodsStreamBuilder extends StatelessWidget {
  final Stream<List<SongModel>> songStream;
  final String currentUserUid;
  final MusicHandler musicHandler;
  final String caption;

  BasedOnListeningHistoryMoodsStreamBuilder({
    required this.songStream,
    required this.currentUserUid,
    required this.musicHandler,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: songStream,
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

          songs = songs.where((song) => song.uid != currentUserUid).toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: songs,
                  onTap: (song) {
                    musicHandler.currentSongs = songs;
                    musicHandler.currentIndex = songs.indexOf(song);
                    musicHandler.setAudioSource(
                        songs[musicHandler.currentIndex], currentUserUid);
                  },
                  caption: caption,
                );
        }
      },
    );
  }
}

class BasedOnListeningHistoryLanguageStreamBuilder extends StatelessWidget {
  final Stream<List<SongModel>> songStream;
  final String currentUserUid;
  final MusicHandler musicHandler;
  final String caption;

  BasedOnListeningHistoryLanguageStreamBuilder({
    required this.songStream,
    required this.currentUserUid,
    required this.musicHandler,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: songStream,
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

          songs = songs.where((song) => song.uid != currentUserUid).toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: songs,
                  onTap: (song) {
                    musicHandler.currentSongs = songs;
                    musicHandler.currentIndex = songs.indexOf(song);
                    musicHandler.setAudioSource(
                        songs[musicHandler.currentIndex], currentUserUid);
                  },
                  caption: caption,
                );
        }
      },
    );
  }
}

class RecommendedPlaylistsGenreStreamBuilder extends StatelessWidget {
  final Stream<List<PlaylistModel>> playlistStream;
  final String caption;

  RecommendedPlaylistsGenreStreamBuilder({
    required this.playlistStream,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlaylistModel>>(
      stream: playlistStream,
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
              caption: caption,
            );
          }
        }
      },
    );
  }
}

class EditorsPlaylistsStreamBuilder extends StatelessWidget {
  final Stream<List<PlaylistModel>> playlistStream;
  final String caption;

  EditorsPlaylistsStreamBuilder({
    required this.playlistStream,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlaylistModel>>(
      stream: playlistStream,
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
              caption: caption,
            );
          }
        }
      },
    );
  }
}

class RecentListeningFutureBuilder extends StatelessWidget {
  final Future<List<SongModel>> futureListeningHistory;
  final MusicHandler musicHandler;
  final String currentUserUid;
  final String caption;

  RecentListeningFutureBuilder({
    required this.futureListeningHistory,
    required this.musicHandler,
    required this.currentUserUid,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SongModel>>(
      future: futureListeningHistory,
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
                    musicHandler.currentSongs = songs;
                    musicHandler.currentIndex = songs.indexOf(song);
                    musicHandler.setAudioSource(
                      songs[musicHandler.currentIndex],
                      currentUserUid,
                    );
                  },
                  caption: caption,
                );
        }
      },
    );
  }
}

class BasedOnLikedSongsStreamBuilder extends StatelessWidget {
  final Stream<List<SongModel>> songStream;
  final MusicHandler musicHandler;
  final String currentUserUid;
  final String caption;

  BasedOnLikedSongsStreamBuilder({
    required this.songStream,
    required this.musicHandler,
    required this.currentUserUid,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: songStream,
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

          songs = songs.where((song) => song.uid != currentUserUid).toList();

          if (songs.length <= 3) {
            return const SizedBox.shrink();
          } else {
            return SongDisplay(
              songs: songs,
              onTap: (song) {
                musicHandler.currentSongs = songs;
                musicHandler.currentIndex = songs.indexOf(song);
                musicHandler.setAudioSource(
                  songs[musicHandler.currentIndex],
                  currentUserUid,
                );
              },
              caption: caption,
            );
          }
        }
      },
    );
  }
}

class BasedOnListeningHistoryStreamBuilder extends StatelessWidget {
  final Stream<List<SongModel>> songStream;
  final MusicHandler musicHandler;
  final String currentUserUid;
  final String caption;

  BasedOnListeningHistoryStreamBuilder({
    required this.songStream,
    required this.musicHandler,
    required this.currentUserUid,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: songStream,
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

          songs = songs.where((song) => song.uid != currentUserUid).toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: songs,
                  onTap: (song) {
                    musicHandler.currentSongs = songs;
                    musicHandler.currentIndex = songs.indexOf(song);
                    musicHandler.setAudioSource(
                      songs[musicHandler.currentIndex],
                      currentUserUid,
                    );
                  },
                  caption: caption,
                );
        }
      },
    );
  }
}

class ArtistsToLookOutStreamBuilder extends StatelessWidget {
  final Stream<List<UserModel>?> userStream;
  final String currentUserUid;
  final String caption;

  ArtistsToLookOutStreamBuilder({
    required this.userStream,
    required this.currentUserUid,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>?>(
      stream: userStream,
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

          users = users.where((user) => user.uid != currentUserUid).toList();
          users.shuffle(random);

          users = users.take(5).toList();

          return users.isEmpty
              ? const SizedBox.shrink()
              : ArtistDisplay(users: users, caption: caption);
        }
      },
    );
  }
}

class NewReleasesStreamBuilder extends StatelessWidget {
  final Stream<List<SongModel>> songStream;
  final MusicHandler musicHandler;
  final String currentUserUid;
  final String caption;

  NewReleasesStreamBuilder({
    required this.songStream,
    required this.musicHandler,
    required this.currentUserUid,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: songStream,
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
          final filteredSongs =
              songs.where((song) => song.createdAt != null).toList();
          final limitedSongs = filteredSongs.take(5).toList();
          musicHandler.latestSong = filteredSongs;

          limitedSongs.shuffle(Random(DateTime.now().minute));
          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: limitedSongs,
                  onTap: (song) {
                    musicHandler.currentSongs = limitedSongs;
                    musicHandler.currentIndex = limitedSongs.indexOf(song);
                    musicHandler.setAudioSource(
                      limitedSongs[musicHandler.currentIndex],
                      currentUserUid,
                    );
                  },
                  caption: caption,
                );
        }
      },
    );
  }
}

class HomeForOPMStreamBuilder extends StatelessWidget {
  final Stream<List<SongModel>> songStream;
  final MusicHandler musicHandler;
  final String currentUserUid;
  final String caption;

  HomeForOPMStreamBuilder({
    required this.songStream,
    required this.musicHandler,
    required this.currentUserUid,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: songStream,
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
          Random random = Random(DateTime.now().minute);

          final songs = snapshot.data!;
          final randomSongs = songs..shuffle(random);
          final limitedSongs = randomSongs.take(5).toList();

          musicHandler.randomSongs = limitedSongs;

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: limitedSongs,
                  onTap: (song) {
                    musicHandler.currentSongs = limitedSongs;
                    musicHandler.currentIndex = limitedSongs.indexOf(song);
                    musicHandler.setAudioSource(
                      limitedSongs[musicHandler.currentIndex],
                      currentUserUid,
                    );
                  },
                  caption: caption,
                );
        }
      },
    );
  }
}

class PopularTracksStreamBuilder extends StatelessWidget {
  final Stream<List<SongModel>> songStream;
  final MusicHandler musicHandler;
  final String currentUserUid;
  final String caption;

  PopularTracksStreamBuilder({
    required this.songStream,
    required this.musicHandler,
    required this.currentUserUid,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: songStream,
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

          musicHandler.randomSongs = topSongs;
          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: topSongs,
                  onTap: (song) {
                    musicHandler.currentSongs = topSongs;
                    musicHandler.currentIndex = topSongs.indexOf(song);
                    musicHandler.setAudioSource(
                      topSongs[musicHandler.currentIndex],
                      currentUserUid,
                    );
                  },
                  caption: caption,
                );
        }
      },
    );
  }
}

class SuggestedSongFromFollowerStreamBuilder extends StatelessWidget {
  final String uid;
  final MusicHandler musicHandler;

  SuggestedSongFromFollowerStreamBuilder({
    required this.uid,
    required this.musicHandler,
  });

  @override
  Widget build(BuildContext context) {
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
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                int index = topSongs.indexWhere(
                                                    (song) =>
                                                        song.songId ==
                                                        user.songId);

                                                final selectedSong =
                                                    topSongs[index];

                                                if (selectedSong != null) {
                                                  musicHandler.currentSongs =
                                                      topSongs;
                                                  musicHandler.currentIndex =
                                                      topSongs.indexOf(
                                                          selectedSong);
                                                  musicHandler.setAudioSource(
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
                                                  },
                                                );
                                              },
                                              child: user.albumCover.isNotEmpty
                                                  ? Container(
                                                      width: 120,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                            spreadRadius: 2,
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        image: user.albumCover
                                                                .isNotEmpty
                                                            ? DecorationImage(
                                                                image: CachedNetworkImageProvider(
                                                                    user.albumCover),
                                                                fit: BoxFit
                                                                    .cover,
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
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 30,
                                                          ),
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
                                          ],
                                        ),
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
