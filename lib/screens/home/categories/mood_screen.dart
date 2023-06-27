import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/categories_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/utils/exports.dart';

import '../../../music_player/music_player.dart';

class MoodsScreen extends StatefulWidget {
  const MoodsScreen({Key? key}) : super(key: key);

  @override
  State<MoodsScreen> createState() => _MoodsScreenState();
}

class _MoodsScreenState extends State<MoodsScreen> {
  final CategoriesController _categoriesCon = CategoriesController();
  Map<String, LinearGradient> moodGradients = {};
  TextEditingController searchController = TextEditingController();
  List<String> moods = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      List<String> fetchedMoods = await _categoriesCon.getDescriptions();
      setState(() {
        moods = fetchedMoods;
      });
    } catch (error) {
      print('Error fetching descriptions: $error');
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

  LinearGradient? getMoodGradient(String mood) {
    if (!moodGradients.containsKey(mood)) {
      moodGradients[mood] = generateRandomGradient();
    }
    return moodGradients[mood];
  }

  void _showMoodSongs(String mood) {
    final gradient = getMoodGradient(mood);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DescriptionSongsScreen(
          description: mood,
          gradient: gradient!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMoods = moods
        .where((mood) =>
            mood.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: moods.isEmpty
          ? const Center(child: LoadingIndicator())
          : Scrollbar(
              child: CustomScrollView(
                slivers: [
                  CustomSliverBar(
                    image: moodPic,
                    title: 'Moods',
                    caption: 'Let your mood guide your next listening choice.',
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
                    children: filteredMoods.map((moods) {
                      final gradient = getMoodGradient(moods);

                      return GestureDetector(
                          onTap: () => _showMoodSongs(moods),
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
                                    moods,
                                    style: GoogleFonts.inter(
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

class DescriptionSongsScreen extends StatelessWidget {
  final String description;
  final LinearGradient gradient;
  DescriptionSongsScreen(
      {Key? key, required this.description, required this.gradient})
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
            title: description,
          ),
          SliverFillRemaining(
            child: FutureBuilder<List<SongModel>>(
              future: _songsCon.getDescriptionSongs(description),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final descriptionSongs = snapshot.data!;
                  return descriptionSongs.isEmpty
                      ? Center(
                          child: Text(
                            "No songs found related \nto $description yet.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: descriptionSongs.length,
                          itemBuilder: (context, index) {
                            final song = descriptionSongs[index];
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
                                            songs: descriptionSongs,
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
