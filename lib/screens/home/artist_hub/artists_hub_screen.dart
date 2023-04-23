import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/library_screen.dart';
import 'package:musikat_app/screens/home/music_player.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/screens/home/artist_hub/insights_screen.dart';
import 'package:musikat_app/screens/home/artist_hub/audio_uploader_screen.dart';

import 'package:musikat_app/utils/exports.dart';
import 'edit_hub_screen.dart';

class ArtistsHubScreen extends StatefulWidget {
  const ArtistsHubScreen({Key? key}) : super(key: key);

  @override
  State<ArtistsHubScreen> createState() => _ArtistsHubScreenState();
}

class _ArtistsHubScreenState extends State<ArtistsHubScreen> {
  final AuthController _auth = locator<AuthController>();
  final SongsController _songCon = SongsController();

  UserModel? user;

  @override
  void initState() {
    UserModel.fromUid(uid: _auth.currentUser!.uid).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    HeaderImage(uid: FirebaseAuth.instance.currentUser!.uid),
                    editButton(),
                    profilePic(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      fullnameText(),
                    ],
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(right: 20.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       Text(
                  //         'Followers: ',
                  //         style: TextStyle(
                  //           color: Colors.grey,
                  //           fontSize: 13.0,
                  //         ),
                  //       ),
                  //       Text(
                  //         '0',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 16.0,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       SizedBox(width: 10.0),
                  //       Text(
                  //         'Following: ',
                  //         style: TextStyle(
                  //           color: Colors.grey,
                  //           fontSize: 13.0,
                  //         ),
                  //       ),
                  //       Text(
                  //         '0',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 16.0,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              usernameText(),
              const SizedBox(height: 10),
              Divider(
                  height: 20,
                  indent: 1.0,
                  color: listileColor.withOpacity(0.4)),
              SizedBox(
                height: 170,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    StreamBuilder<List<SongModel>>(
                      stream: _songCon.getLatestSong(
                          FirebaseAuth.instance.currentUser!.uid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Container();
                        }

                        if (snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              "No songs found in your library",
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                  child: Text('Latest Release',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: InkWell(
                                      onLongPress: () {
                                        showModalBottomSheet(
                                            backgroundColor: musikatColor4,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return SingleChildScrollView(
                                                child: SongBottomField(
                                                  songId: latestSong.songId,
                                                ),
                                              );
                                            });
                                      },
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MusicPlayerScreen(
                                                      songs: [latestSong],
                                                      // username: latestSong.artist,
                                                    )));
                                      },
                                      child: Container(
                                        height: 105,
                                        width: 110,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                latestSong.albumCover),
                                            fit: BoxFit.cover,
                                          ),
                                          color: Colors.grey.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        latestSong.title.length > 20
                                            ? '${latestSong.title.substring(0, 20)}...'
                                            : latestSong.title,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(latestSong.genre,
                                          style: GoogleFonts.inter(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, top: 15, bottom: 10),
                  child: Text("Artist's Hub",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              SingleChildScrollView(
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
                        icon: Icons.upload_file,
                        text: 'Upload a file',
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
                        icon: Icons.money,
                        text: 'Support',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Align usernameText() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(user?.username ?? '',
            style: GoogleFonts.inter(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Align fullnameText() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(
          '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Positioned editButton() {
    return Positioned(
      right: 12,
      bottom: 65,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EditHubScreen(),
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
}
