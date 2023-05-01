import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/music_player.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';

import 'package:musikat_app/utils/exports.dart';

class HomeScreen extends StatefulWidget {
  static const String route = 'home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SongsController _songCon = SongsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.only(left: 25, top: 25),
              alignment: Alignment.topLeft,
              child: Text("Home For OPM",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<List<SongModel>>(
                stream: _songCon.getSongsStream(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<SongModel>> snapshot) {
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

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: limitedSongs.map((song) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 25, top: 10),
                            child: GestureDetector(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MusicPlayerScreen(
                                                songs: songs,
                                                initialIndex:
                                                    limitedSongs.indexOf(song),
                                              )),
                                    ),
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 124, 131, 127),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                          image: NetworkImage(song.albumCover),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    song.title.length > 19
                                        ? '${song.title.substring(0, 19)}..'
                                        : song.title,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 2,
                                    ),
                                  ),
                                  Text(
                                    song.artist,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 13,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                }),
            Container(
              padding: const EdgeInsets.only(left: 25, top: 25),
              alignment: Alignment.topLeft,
              child: Text("What's New?",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 124, 131, 127),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                image: const DecorationImage(
                                  image:
                                      AssetImage("assets/images/albumdes.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Daily Mix 3",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 2,
                                ),
                              ),
                            ),
                            Text(
                              "Musikat",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 124, 131, 127),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      "assets/images/homescreen/album2.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Daily Mix 3",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 2,
                                ),
                              ),
                            ),
                            Text(
                              "Musikat",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 124, 131, 127),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      "assets/images/homescreen/ticket3.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Daily Mix 3",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 2,
                                ),
                              ),
                            ),
                            Text(
                              "Musikat",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 25, top: 25),
              alignment: Alignment.topLeft,
              child: Text("Artist to Look Out For",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<List<UserModel>>(
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
                      .where((user) =>
                          user.uid != FirebaseAuth.instance.currentUser!.uid)
                      .toList();
                  users.shuffle(random);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: users
                            .take(5)
                            .map((user) => Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, top: 10),
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
                                                          image: NetworkImage(
                                                              user.profileImage),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            user.username,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              fontSize: 13,
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
                  );
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}
