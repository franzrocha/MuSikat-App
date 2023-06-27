import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/categories_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({Key? key}) : super(key: key);

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  final CategoriesController _categoriesCon = CategoriesController();
  Map<String, LinearGradient> genreGradients = {};
  TextEditingController searchController = TextEditingController();
  List<String> genres = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      List<String> fetchedGenres = await _categoriesCon.getGenres();
      setState(() {
        genres = fetchedGenres;
      });
    } catch (error) {
      print('Error fetching genres: $error');
    }
  }

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

  LinearGradient? getGenreGradient(String genre) {
    if (!genreGradients.containsKey(genre)) {
      genreGradients[genre] = generateRandomGradient();
    }
    return genreGradients[genre];
  }

  void _showGenreSongs(String genre) {
    final gradient = getGenreGradient(genre);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenreSongsScreen(
          genre: genre,
          gradient: gradient!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredGenres = genres
        .where((genre) =>
            genre.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: genres.isEmpty
          ? const Center(child: LoadingIndicator())
          : Scrollbar(
              child: CustomScrollView(
                slivers: [
                  CustomSliverBar(
                    image: genrePic,
                    title: 'Genres',
                    caption: 'Genres that might suit your taste.',
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16),
                      width: 400,
                      child: TextField(
                        style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 13),
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                  SliverGrid.count(
                    crossAxisCount: 2,
                    children: filteredGenres.map((genre) {
                      final gradient = getGenreGradient(genre);

                      return GestureDetector(
                        onTap: () => _showGenreSongs(genre),
                        child: SizedBox(
                          height: 200,
                          child: Container(
                            margin: const EdgeInsets.all(16.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              gradient: gradient,
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
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

class GenreSongsScreen extends StatelessWidget {
  final String genre;
  final LinearGradient gradient;

  GenreSongsScreen({Key? key, required this.genre, required this.gradient})
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
            title: genre,
          ),
          SliverFillRemaining(
            child: FutureBuilder<List<SongModel>>(
              future: _songsCon.getGenreSongs(genre),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final genreSongs = snapshot.data!;

                  return genreSongs.isEmpty
                      ? Center(
                          child: Text(
                            "No songs found for $genre.",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
                                            songs: genreSongs,
                                            initialIndex: index,
                                            
                                          )),
                                );
                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                    backgroundColor: musikatColor4,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                        child: SongBottomField(
                                          song: song,
                                          hideRemoveToPlaylist: true,
                                          hideDelete: true,
                                          hideEdit: true,
                                           hideLike: false,
                                        ),
                                      );
                                    });
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
