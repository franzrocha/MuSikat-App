import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/controllers/following_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/edit_profile_screen.dart';
import 'package:musikat_app/screens/home/artist_hub/library_screen.dart';
import 'package:musikat_app/screens/home/artist_hub/insights_screen.dart';
import 'package:musikat_app/screens/home/artist_hub/audio_uploader_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import '../../../music_player/music_handler.dart';

class ArtistsHubScreen extends StatefulWidget {
  final MusicHandler musicHandler;
  const ArtistsHubScreen({
    Key? key,
    required this.musicHandler,
  }) : super(key: key);

  @override
  State<ArtistsHubScreen> createState() => _ArtistsHubScreenState();
}

class _ArtistsHubScreenState extends State<ArtistsHubScreen> {
  final SongsController _songCon = SongsController();
  final FollowController _followCon = FollowController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: musikatBackgroundColor,
        body: SafeArea(
          child: StreamBuilder<UserModel>(
            stream: UserModel.fromUidStream(
                uid: FirebaseAuth.instance.currentUser!.uid),
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
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            HeaderImage(
                                uid: FirebaseAuth.instance.currentUser!.uid),
                            editButton(snapshot),
                            profilePic(),
                          ],
                        ),
                      ),
                      usernameText(snapshot),
                      fullnameText(snapshot),
                      const SizedBox(height: 10),
                      followings(),
                      Divider(
                          height: 20,
                          indent: 1.0,
                          color: listileColor.withOpacity(0.4)),
                      latestRelease(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30, top: 15, bottom: 10),
                          child: Text(
                            "Artist's Hub",
                            style: sloganStyle,
                          ),
                        ),
                      ),
                      artistHub(context),
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              }
            },
          ),
        ));
  }

  SingleChildScrollView artistHub(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CardTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AudioUploaderScreen(),
                ));
              },
              icon: Icons.upload_file_rounded,
              text: 'Upload a song',
            ),
            CardTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LibraryScreen(),
                ));
              },
              icon: Icons.library_music,
              text: 'Library',
            ),
            CardTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const InsightsScreen(),
                ));
              },
              icon: Icons.stacked_bar_chart,
              text: 'Insights',
            ),
            CardTile(
              onTap: () {},
              icon: Icons.monetization_on,
              text: 'Support',
            ),
          ],
        ),
      ),
    );
  }

  SizedBox latestRelease() {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          StreamBuilder<List<SongModel>>(
            stream:
                _songCon.getLatestSong(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Container();
              }

              if (snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    "No songs found in your library.",
                    style: shortThinStyle,
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

                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 30, top: 10, bottom: 15),
                        child: Text(
                          'Latest Release',
                          style: sloganStyle,
                        ),
                      ),
                    ),
                    InkWell(
                      onLongPress: () {
                        showModalBottomSheet(
                            backgroundColor: musikatColor4,
                            context: context,
                            builder: (BuildContext context) {
                              return SingleChildScrollView(
                                child: SongBottomField(
                                  song: latestSong,
                                  hideRemoveToPlaylist: true,
                                  hideLike: false,
                                ),
                              );
                            });
                      },
                      onTap: () {
                        widget.musicHandler.currentSongs = [latestSong];
                        widget.musicHandler.currentIndex = 0;
                        widget.musicHandler.setAudioSource(latestSong, uid);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
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
                              const SizedBox(height: 5),
                              Text(
                                DateFormat("MMMM d, y")
                                    .format(latestSong.createdAt),
                                style: artistStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Align usernameText(snapshot) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(snapshot.data!.username, style: mediumDefault),
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
          style: shortDefaultGrey,
        ),
      ),
    );
  }

  Positioned editButton(snapshot) {
    return Positioned(
      right: 12,
      bottom: 65,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditProfileScreen(user: snapshot.data!),
              ));
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: const Center(
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
              child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
            ),
          ],
        ),
      ),
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
              stream: _followCon.getUserFollowers(uid).asStream(),
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
              stream: _followCon.getUserFollowing(uid).asStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
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
}
