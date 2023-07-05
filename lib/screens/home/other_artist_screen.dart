// ignore_for_file: must_be_immutable
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/chat/chat_screen_private.dart';
import 'package:musikat_app/controllers/following_controller.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/controllers/notification_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/screens/home/chat/private_chat.dart';
import 'package:musikat_app/screens/home/profile/playlist_detail_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/widgets/display_widgets.dart';

class ArtistsProfileScreen extends StatefulWidget {
  ArtistsProfileScreen({Key? key, required this.selectedUserUID})
      : super(key: key);
  String selectedUserUID;

  @override
  State<ArtistsProfileScreen> createState() => _ArtistsProfileScreenState();
}

class _ArtistsProfileScreenState extends State<ArtistsProfileScreen> {
  @override
  void dispose() {
    Get.delete<FollowController>();
    super.dispose();
  }

  final SongsController _songCon = SongsController();
  final FollowController _followCon = Get.put(FollowController());

  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  final userNotification = UserNotificationController();

  final PlaylistController _playlistCon = PlaylistController();
  String get selectedUserUID => widget.selectedUserUID;
  UserModel? user;
  int followers = 0;
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showLogo: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivateChatScreen(
                    selectedUserUID: selectedUserUID,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.monetization_on),
          ),
        ],
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<UserModel>(
            stream: UserModel.fromUidStream(uid: selectedUserUID),
            builder: (context, AsyncSnapshot<UserModel?> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Container();
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                return SingleChildScrollView(
                  child: Column(children: [
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          HeaderImage(uid: selectedUserUID),
                          profilePic(),
                        ],
                      ),
                    ),
                    usernameText(snapshot, isFollowing),
                    fullnameText(snapshot),
                    followings(),
                    artistsButton(),
                    Divider(
                        height: 20,
                        indent: 1.0,
                        color: listileColor.withOpacity(0.4)),
                    latestSong(),
                    topTracks(),
                    librarySongs(),
                    playlists(),
                  ]),
                );
              }
            }),
      ),
    );
  }

  Row artistsButton() {
    return Row(
      children: [
        const SizedBox(width: 30.0),
        StreamBuilder<List<String>>(
          stream: _followCon.getUserFollowing(currentUser).asStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 130.0,
                child: ElevatedButton(child: null, onPressed: null),
              );
            } else if (snapshot.hasData) {
              final followingList = snapshot.data;
              final selectedUserFollows =
                  followingList?.contains(selectedUserUID) ?? false;

              return SizedBox(
                width: 130.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!selectedUserFollows) {
                      _followCon.followUser(selectedUserUID);

                      userNotification.addUserNotification(selectedUserUID, 1);

                      followers++;
                    } else {
                      _followCon.unfollowUser(selectedUserUID);
                      userNotification.deleteNotification(selectedUserUID);

                      followers--;
                    }

                    isFollowing = !selectedUserFollows;
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color.fromARGB(255, 0, 0, 0);
                      } else if (isFollowing) {
                        return Colors.grey;
                      } else if (selectedUserFollows) {
                        return Colors.grey;
                      } else {
                        return const Color(0xfffca311);
                      }
                    }),
                  ),
                  child: Text(selectedUserFollows ? 'Unfollow' : 'Follow'),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const SizedBox(
                width: 130.0,
                child: ElevatedButton(child: null, onPressed: null),
              );
            }
          },
        ),
      ],
    );
  }

  SizedBox followings() {
    return SizedBox(
      height: 35,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
        child: Row(
          children: [
            StreamBuilder<List<String>>(
              stream: _followCon.getUserFollowers(selectedUserUID).asStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasData) {
                  final followersCount = snapshot.data!.length;
                  return Text(
                    '$followersCount followers',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13.0,
                    ),
                  );
                } else {
                  return const Text(
                    '0 followers',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13.0,
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 30.0),
            StreamBuilder<List<String>>(
              stream: _followCon.getUserFollowing(selectedUserUID).asStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  final followingList = snapshot.data;

                  _followCon.setSelectedArtistFollowsCurrentUser(
                      currentUser, followingList!);

                  final followingCount = snapshot.data!.length;
                  return Text(
                    '$followingCount following',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13.0,
                    ),
                  );
                } else {
                  return const Text(
                    '0 following',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13.0,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  SizedBox playlists() {
    return SizedBox(
      height: 250,
      child: StreamBuilder<List<PlaylistModel>>(
          stream: _playlistCon.getPlaylistStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox.shrink();
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            } else {
              final playlists = snapshot.data!
                  .where((playlist) => playlist.uid == widget.selectedUserUID)
                  .toList();

              if (playlists.isEmpty) {
                return const SizedBox.shrink();
              } else {
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
                    caption: 'Playlists');
              }
            }
          }),
    );
  }

  StreamBuilder<List<SongModel>> librarySongs() {
    return StreamBuilder<List<SongModel>>(
      stream: _songCon.getSongsStream(),
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
          final songs = snapshot.data!
              .where((song) => song.uid == widget.selectedUserUID)
              .toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SongDisplay(
                  songs: songs,
                  onTap: (song) => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MusicPlayerScreen(
                            songs: songs,
                            initialIndex: songs.indexOf(song),
                          ),
                        ),
                      ),
                  caption: 'Library');
        }
      },
    );
  }

  FutureBuilder<List<SongModel>> topTracks() {
    return FutureBuilder<List<SongModel>>(
      future: _songCon.getRankedSongs(widget.selectedUserUID),
      builder: (BuildContext context, AsyncSnapshot<List<SongModel>> snapshot) {
        if (snapshot.hasData) {
          final List<SongModel> songs = snapshot.data!
              .where((song) => song.uid == widget.selectedUserUID)
              .toList();

              songs.take(5).toList();

          return songs.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, bottom: 10),
                          child: Text(
                            'Top tracks',
                            style: sloganStyle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: calculateHeight(songs.length > 5 ? 5 : songs.length),
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final SongModel song = songs[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => MusicPlayerScreen(
                                              songs: songs,
                                              initialIndex: index,
                                            )),
                                  );
                                },
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          song.albumCover),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${index + 1}.  ${song.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: songTitle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Container();
        }
      },
    );
  }

  SizedBox latestSong() {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: StreamBuilder<List<SongModel>>(
          stream: _songCon.getLatestSong(selectedUserUID),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container();
            }

            if (snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    "The user hasn't uploaded any songs yet.",
                    style: shortThinStyle,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              final latestSong = snapshot.data!.first;

              return Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding:
                          const EdgeInsets.only(left: 30, top: 10, bottom: 15),
                      child: Text(
                        'Latest Release',
                        style: sloganStyle,
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MusicPlayerScreen(
                                songs: [latestSong],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  latestSong.albumCover),
                              fit: BoxFit.cover,
                            ),
                            color: Colors.grey.withOpacity(0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latestSong.title.length > 30
                              ? '${latestSong.title.substring(0, 30)}...'
                              : latestSong.title,
                          style: songTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat("MMMM d, y").format(latestSong.createdAt),
                          style: artistStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ]);
            }
          }),
    );
  }

  Align profilePic() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 30, bottom: 10),
        child: Stack(
          children: [
            SizedBox(
              width: 100,
              height: 120,
              child: AvatarImage(uid: selectedUserUID),
            ),
          ],
        ),
      ),
    );
  }

  Align usernameText(snapshot, bool isFollowing) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(snapshot.data!.username, style: mediumDefault),
            const SizedBox(width: 10),
            Obx(
              () => _followCon.artistIsFollowingUser
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 1.0,
                        ),
                      ),
                      child: SizedBox(
                        width: 90,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Follows you',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            )
          ],
        ),
      ),
    );
  }

  Align fullnameText(snapshot) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(
          '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
          style: GoogleFonts.inter(
              color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  double calculateHeight(int length) {
    if (length == 5) {
      return 280;
    } else if (length == 4) {
      return 240;
    } else if (length == 3) {
      return 180;
    } else if (length == 2) {
      return 130;
    } else if (length == 1) {
      return 100;
    } else {
      return 0;
    }
  }
}
