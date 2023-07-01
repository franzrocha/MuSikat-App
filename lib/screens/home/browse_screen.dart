import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/screens/home/categories/genres_screen.dart';
import 'package:musikat_app/screens/home/categories/language_screen.dart';
import 'package:musikat_app/screens/home/categories/mood_screen.dart';
import 'package:musikat_app/screens/home/profile/playlist_detail_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/widgets/display_widgets.dart';
import 'package:musikat_app/widgets/search_bar.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final PlaylistController _playCon = PlaylistController();
  List<String> genres = [];

  @override
  void initState() {
    super.initState();
    fetchUniqueGenres();
  }

  Future<void> fetchUniqueGenres() async {
    List<String> uniqueGenres = await _playCon.getUniqueGenres();

    setState(() {
      genres = uniqueGenres;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Searchbar(),
            categories(context),
            for (int i = 0; i < genres.length; i++) getPlaylist(genres[i]),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  StreamBuilder<List<PlaylistModel>> getPlaylist(String genre) {
    return StreamBuilder<List<PlaylistModel>>(
      stream: _playCon.getPlaylistStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoadingContainer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingContainer();
        } else {
          List<PlaylistModel> playlists = snapshot.data!;

          playlists = playlists
              .where((playlist) =>
                  playlist.isOfficial == true && playlist.genre == genre && playlist.genre != 'Random')
              .toList();

          return playlists.isEmpty
              ? const SizedBox.shrink()
              : PlaylistDisplay(
                  playlists: playlists,
                  onTap: (playlist) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              PlaylistDetailScreen(playlist: playlist)),
                    );
                  },
                  caption: genre);
        }
      },
    );
  }

  Column categories(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 10),
            child: Container(
              padding: const EdgeInsets.only(top: 25),
              child: Text(
                'Categories to explore',
                textAlign: TextAlign.right,
                style: sloganStyle,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 10),
                child: Row(
                  children: [
                    CategoryCard(
                      image: genrePic,
                      text: 'Genres',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GenresScreen(),
                          ),
                        );
                      },
                    ),
                    CategoryCard(
                      image: languagePic,
                      text: 'Languages',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguagesScreen(),
                          ),
                        );
                      },
                    ),
                    CategoryCard(
                      image: moodPic,
                      text: 'Moods',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoodsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
