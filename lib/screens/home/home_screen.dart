import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
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
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 2,
                                  ),
                                ),
                                Text(
                                  song.artist,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.2,
                                  ),
                                ),
                              ],
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
                                  fit: BoxFit.cover, //change image fill type
                                ),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Daily Mix 3",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 2,
                                ),
                              ),
                            ),
                            const Text(
                              "Musikat",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
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
                                  fit: BoxFit.cover, //change image fill type
                                ),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Daily Mix 3",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 2,
                                ),
                              ),
                            ),
                            const Text(
                              "Musikat",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
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
                                  fit: BoxFit.cover, //change image fill type
                                ),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Daily Mix 3",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 2,
                                ),
                              ),
                            ),
                            const Text(
                              "Musikat",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
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
              child: Text("Artist Of The Week",
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 10),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        "assets/images/homescreen/range.jpg"),
                                    fit: BoxFit.cover, //change image fill type
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Juan Bautista",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 10),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        "assets/images/homescreen/rpg.jpg"),
                                    fit: BoxFit.cover, //change image fill type
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Jacob Reyes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 10),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        "assets/images/homescreen/jeper.jpg"),
                                    fit: BoxFit.cover, //change image fill type
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Ezekiel Dy",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 10),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        "assets/images/homescreen/winston.jpg"),
                                    fit: BoxFit.cover, //change image fill type
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Gabriel Garcia",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

