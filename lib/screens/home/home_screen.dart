import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/liked_songs_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/recently_played.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import '../../music_player/music_handler.dart';

class HomeScreen extends StatefulWidget {
  final MusicHandler musicHandler;
  static const String route = 'home-screen';

  const HomeScreen({Key? key, required this.musicHandler}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SongsController _songCon = SongsController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<SongModel>>? _songsStream;
  StreamSubscription? _timerSubscription;

  @override
  void initState() {
    super.initState();

    _songsStream = _createSongsStream();
    _timerSubscription = Stream.periodic(const Duration(minutes: 5))
        .switchMap((_) => _createSongsStream())
        .listen((songs) {
      setState(() {});
    });
  }

  Stream<List<SongModel>> _createSongsStream() {
    final now = DateTime.now();
    if (now.minute < 1) {
      return RecentlyPlayedModel.getRecommendedSongs(byGenre: false).asStream();
    } else {
      return RecentlyPlayedModel.getRecommendedSongs().asStream();
    }
  }

  @override
  void dispose() {
    _timerSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 5),
            homeForOPM(),
            newReleases(),
            artiststToLookOut(),
            basedOnListeningHistory(),
            basedOnLikedSongs(),
            const SizedBox(height: 5),
          ]),
        ),
      ),
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

          // songs = songs
          //     .where((song) =>
          //         song.songId != FirebaseAuth.instance.currentUser!.uid)
          //     .toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 30, bottom: 10),
                          child: buildCustomContainer(
                              'Based on your liked songs...')),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: songs.map((song) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 25, top: 10),
                            child: GestureDetector(
                              onTap: () {
                                widget.musicHandler.currentSongs = songs;
                                widget.musicHandler.currentIndex =
                                    songs.indexOf(song);
                                widget.musicHandler.setAudioSource(song, uid);
                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                    backgroundColor: musikatColor4,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                        child: SongBottomField(
                                          song: song,
                                          hideEdit: true,
                                          hideDelete: true,
                                          hideRemoveToPlaylist: true,
                                        ),
                                      );
                                    });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 124, 131, 127),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            song.albumCover),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    song.title.length > 19
                                        ? '${song.title.substring(0, 19)}..'
                                        : song.title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 2,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    song.artist,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
        }
      },
    );
  }

  StreamBuilder<List<SongModel>> basedOnListeningHistory() {
    return StreamBuilder<List<SongModel>>(
      stream: _songsStream,
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

          // songs = songs
          //     .where((song) =>
          //         song.songId != FirebaseAuth.instance.currentUser!.uid)
          //     .toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 30, bottom: 10),
                          child: buildCustomContainer(
                              'Based on your listening activity...')),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: songs.map((song) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 25, top: 10),
                            child: GestureDetector(
                              onTap: () {
                                widget.musicHandler.currentSongs = songs;
                                widget.musicHandler.currentIndex =
                                    songs.indexOf(song);
                                widget.musicHandler.setAudioSource(song, uid);
                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                    backgroundColor: musikatColor4,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                        child: SongBottomField(
                                          song: song,
                                          hideEdit: true,
                                          hideDelete: true,
                                          hideRemoveToPlaylist: true,
                                        ),
                                      );
                                    });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 124, 131, 127),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            song.albumCover),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    song.title.length > 19
                                        ? '${song.title.substring(0, 19)}..'
                                        : song.title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 2,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    song.artist,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
        }
      },
    );
  }

  StreamBuilder<List<UserModel>> artiststToLookOut() {
    return StreamBuilder<List<UserModel>>(
      stream: UserModel.getUsers().asStream(),
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
          Random random = Random(DateTime.now().day);

          users = users
              .where(
                  (user) => user.uid != FirebaseAuth.instance.currentUser!.uid)
              .toList();
          users.shuffle(random);

          return users.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 30, bottom: 10),
                          child: buildCustomContainer(
                              'Artists to look out for...')),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: users
                              .take(5)
                              .map((user) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25, top: 10),
                                    child: Column(
                                      children: [
                                        Column(children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ArtistsProfileScreen(
                                                            selectedUserUID:
                                                                user.uid,
                                                          )));
                                            },
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 77, 69, 69),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                image:
                                                    user.profileImage.isNotEmpty
                                                        ? DecorationImage(
                                                            image: CachedNetworkImageProvider(
                                                                user.profileImage),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              user.username,
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 11,
                                                height: 2,
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                );
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
            final limitedSongs = songs.take(5).toList();
            widget.musicHandler.latestSong = songs;

            return songs.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, bottom: 10),
                          child: buildCustomContainer('What\'s New?'),
                        ),
                      ),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: limitedSongs.map((song) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 25, top: 10),
                              child: GestureDetector(
                                onTap: () {
                                  widget.musicHandler.currentSongs =
                                      limitedSongs;
                                  widget.musicHandler.currentIndex =
                                      limitedSongs.indexOf(song);
                                  widget.musicHandler.setAudioSource(song, uid);
                                },
                                onLongPress: () {
                                  showModalBottomSheet(
                                      backgroundColor: musikatColor4,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SingleChildScrollView(
                                          child: SongBottomField(
                                            song: song,
                                            hideEdit: true,
                                            hideDelete: true,
                                            hideRemoveToPlaylist: true,
                                          ),
                                        );
                                      });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 124, 131, 127),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              song.albumCover),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      song.title.length > 19
                                          ? '${song.title.substring(0, 19)}..'
                                          : song.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 2,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      song.artist,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 10,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
            final songs = snapshot.data!;
            final randomSongs = songs..shuffle();
            final limitedSongs = randomSongs.take(5).toList();
            widget.musicHandler.randomSongs = limitedSongs;

            return songs.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, bottom: 10),
                              child: buildCustomContainer('Home for OPM')),
                        ),
                        SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: limitedSongs.map((song) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, top: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.musicHandler.currentSongs =
                                          limitedSongs;
                                      widget.musicHandler.currentIndex =
                                          limitedSongs.indexOf(song);
                                      widget.musicHandler.setAudioSource(
                                          limitedSongs[
                                              widget.musicHandler.currentIndex],
                                          uid);
                                    },
                                    onLongPress: () {
                                      showModalBottomSheet(
                                          backgroundColor: musikatColor4,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SingleChildScrollView(
                                              child: SongBottomField(
                                                song: song,
                                                hideEdit: true,
                                                hideDelete: true,
                                                hideRemoveToPlaylist: true,
                                              ),
                                            );
                                          });
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 124, 131, 127),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  song.albumCover),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          song.title.length > 19
                                              ? '${song.title.substring(0, 19)}..'
                                              : song.title,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            height: 2,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          song.artist,
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontSize: 10,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            )),
                      ]);
          }
        });
  }

  Container buildCustomContainer(String text) {
    return Container(
      padding: const EdgeInsets.only(top: 25),
      alignment: Alignment.topLeft,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: GoogleFonts.inter(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
