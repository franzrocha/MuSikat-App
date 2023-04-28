import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/screens/home/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({Key? key}) : super(key: key);

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
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

  void _showGenreSongs(String genre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenreSongsScreen(genre: genre),
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
            image: genrePic,
            title: 'Genres',
            caption: 'All genres that might suit your taste.',
          ),
          SliverGrid.count(
            crossAxisCount: 2,
            children: genres.map((genre) {
              return GestureDetector(
                  onTap: () => _showGenreSongs(genre),
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
                            genre,
                            style: const TextStyle(
                              fontSize: 20.0,
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

class GenreSongsScreen extends StatelessWidget {
  final String genre;

  GenreSongsScreen({Key? key, required this.genre}) : super(key: key);

  final SongsController _songsCon = SongsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: musikatBackgroundColor,
        title: Text(genre),
      ),
      backgroundColor: musikatBackgroundColor,
      body: FutureBuilder<List<SongModel>>(
        future: _songsCon.getGenreSongs(genre),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final genreSongs = snapshot.data!;

            return genreSongs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 150),
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: Image.asset("assets/images/no_music.png",
                                width: 230, height: 230),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No $genre songs yet",
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: genreSongs.length,
                    itemBuilder: (context, index) {
                      final song = genreSongs[index];
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
                                      songs: genreSongs,
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
    );
  }
}
