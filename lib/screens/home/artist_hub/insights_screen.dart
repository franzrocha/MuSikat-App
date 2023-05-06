import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/song_plays_screen.dart';
import 'package:musikat_app/screens/home/artist_hub/user_like_screen.dart';
import 'package:musikat_app/utils/exports.dart';

import '../../../models/song_model.dart';

class InsightsScreen extends StatefulWidget {
  static const String route = 'artists-screen';

  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final SongsController _songCon = SongsController();
  //SongModel? song;
  UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Insights',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(children: [
            FutureBuilder<int>(
              future: _songCon.getUserSongCount(),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // return Text('Songs uploaded: ${snapshot.data}',
                  //     style: const TextStyle(color: Colors.white));
                  return ListTile(
                    trailing: Text(
                      '${snapshot.data}',
                      style: const TextStyle(
                        fontSize:
                            20, // change the font size as per your requirement
                        color: Colors
                            .white, // change the color as per your requirement
                      ),
                    ),
                    title: Text(
                      'Songs Uploaded',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  );
                }
              },
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Song Plays',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const SongPlaysScreen()),
                );
              },
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Likes',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserLikeScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              title: Text(
                'Top Tracks',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.normal),
              ),
              // onTap: () {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(builder: (context) => SongRankingPage()),
              //   );
              // },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: _songCon.getRankedSongs(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<SongModel>> snapshot) {
                  if (snapshot.hasData) {
                    final List<SongModel> songs = snapshot.data!;
                    return ListView.separated(
                      itemCount: songs.length > 5 ? 5 : songs.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final SongModel song = songs[index];
                        return ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    CachedNetworkImageProvider(song.albumCover),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return const Center(
                      child: LoadingIndicator(),
                    );
                  }
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
