import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({Key? key}) : super(key: key);

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  LinearGradient generateRandomGradient() {
    final random = Random();
    final color1 = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    final color2 = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color1, color2],
    );
  }

  void _showLanguageSongs(String languages) {
    final gradient = generateRandomGradient();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LanguageSongsScreen(languages: languages, gradient: gradient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomSliverBar(
            image: languagePic,
            title: 'Languages',
            caption:
                'Expand your music horizons with ethno-languages from the Philippines.',
          ),
          SliverGrid.count(
            crossAxisCount: 2,
            children: languages.map((languages) {
              return GestureDetector(
                  onTap: () => _showLanguageSongs(languages),
                  child: SizedBox(
                    height: 200,
                    child: Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: generateRandomGradient(),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            spreadRadius: 0.5,
                            offset: Offset(2.0, 2.0),
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languages,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class LanguageSongsScreen extends StatelessWidget {
  final String languages;
  final LinearGradient gradient;
  LanguageSongsScreen(
      {Key? key, required this.languages, required this.gradient})
      : super(key: key);

  final SongsController _songsCon = SongsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomSliverBar(
            linearGradient: gradient,
            title: languages,
          ),
          SliverFillRemaining(
            child: FutureBuilder<List<SongModel>>(
              future: _songsCon.getAllLanguageSongs(languages),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final languageSongs = snapshot.data!;
                  return languageSongs.isEmpty
                      ? Center(
                          child: Text(
                            "No songs found for $languages.",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: languageSongs.length,
                          itemBuilder: (context, index) {
                            final song = languageSongs[index];
                            return ListTile(
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
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 16),
                              ),
                              subtitle: Text(song.artist,
                                  style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 14)),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => MusicPlayerScreen(
                                            songs: languageSongs,
                                            initialIndex: index,
                                          )),
                                );
                              },
                            );
                          },
                        );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
