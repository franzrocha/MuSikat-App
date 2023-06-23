import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/categories_controller.dart';
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
  final CategoriesController _categoriesCon = CategoriesController();
  Map<String, LinearGradient> languageGradients = {};
  TextEditingController searchController = TextEditingController();
  List<String> languages = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      List<String> fetchedLanguages = await _categoriesCon.getLanguages();
      setState(() {
        languages = fetchedLanguages;
      });
    } catch (error) {
      print('Error fetching languages: $error');
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

  LinearGradient? getLanguageGradient(String language) {
    if (!languageGradients.containsKey(language)) {
      languageGradients[language] = generateRandomGradient();
    }
    return languageGradients[language];
  }

  void _showLanguageSongs(String language) {
    final gradient = getLanguageGradient(language);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageSongsScreen(
          languages: language,
          gradient: gradient!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = languages
        .where((language) => language
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: languages.isEmpty
          ? const Center(child: LoadingIndicator())
          : Scrollbar(
              child: CustomScrollView(
                slivers: [
                  CustomSliverBar(
                    image: languagePic,
                    title: 'Languages',
                    caption:
                        'Expand your music horizons with ethno-languages from the Philippines.',
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
                          fillColor: Colors.transparent,
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
                    children: filteredLanguages.map((language) {
                      final gradient = getLanguageGradient(language);

                      return GestureDetector(
                          onTap: () => _showLanguageSongs(language),
                          child: SizedBox(
                            height: 200,
                            child: Container(
                              margin: const EdgeInsets.all(16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0)),
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
                                    language,
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
                                            recommendedSongs: [],
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
