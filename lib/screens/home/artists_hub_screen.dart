import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/library_screen.dart';
import 'package:musikat_app/screens/home/music_player.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/screens/home/artist_hub/insights.dart';
import 'package:musikat_app/screens/home/artist_hub/audio_uploader_screen.dart';
import 'package:musikat_app/widgets/avatar.dart';
import 'package:musikat_app/widgets/card_tile.dart';
import 'package:musikat_app/widgets/header_image.dart';

import '../../widgets/loading_indicator.dart';
import 'artist_hub/edit_hub_screen.dart';

class ArtistsHubScreen extends StatefulWidget {
  const ArtistsHubScreen({Key? key}) : super(key: key);

  @override
  State<ArtistsHubScreen> createState() => _ArtistsHubScreenState();
}

class _ArtistsHubScreenState extends State<ArtistsHubScreen> {
  final AuthController _auth = locator<AuthController>();
  final SongService songService = SongService();

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
                height: 230,
                child: Stack(children: [
                  HeaderImage(uid: FirebaseAuth.instance.currentUser!.uid),
                  editButton(),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: profilePic(),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 40,
                    child: Text(user?.username ?? '',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 40,
                    child: Text('@${user?.username ?? ''}',
                        style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
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
                    const SizedBox(height: 15),
                    StreamBuilder<SongModel>(
                      stream: songService.getLatestSong(
                          FirebaseAuth.instance.currentUser!.uid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return StreamBuilder<Object>(
                              stream: null,
                              builder: (context, snapshot) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Text(
                                    "No songs found in your library",
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                );
                              });
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else {
                          final latestSong = snapshot.data!;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: InkWell(
                                  // onTap: () {
                                  //   Navigator.of(context).push(
                                  //       MaterialPageRoute(
                                  //           builder: (context) =>
                                  //               MusicPlayerScreen(
                                  //                 song: latestSong,
                                  //                 username: user!.username,
                                  //               )));
                                  // },
                                  child: Container(
                                    height: 105,
                                    width: 110,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(latestSong.albumCover),
                                        fit: BoxFit.cover,
                                      ),
                                      color: Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Latest Release',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text(latestSong.title,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text(latestSong.genre,
                                      style: GoogleFonts.inter(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      )),
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
              Padding(
                padding: const EdgeInsets.only(right: 260, top: 5, bottom: 10),
                child: Text("Artist's Hub",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Scrollbar(
                    child: Row(
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
                          icon: Icons.monetization_on,
                          text: 'Patreon',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned editButton() {
    return Positioned(
      right: 12,
      bottom: 95,
      child: Stack(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const EditHubScreen(),
                  ));
                },
                child: const Icon(
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

  Padding profilePic() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Stack(
        children: [
          SizedBox(
            width: 100,
            height: 120,
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
        ],
      ),
    );
  }
}
