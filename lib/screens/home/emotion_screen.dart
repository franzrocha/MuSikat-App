import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/utils/exports.dart';

import '../../../music_player/music_player.dart';

import 'dart:math';

class EmotionDisplayScreen extends StatefulWidget {
  final String emotion;

  const EmotionDisplayScreen({
    Key? key,
    required this.emotion,
  }) : super(key: key);

  @override
  State<EmotionDisplayScreen> createState() => _EmotionDisplayScreenState();
}

class _EmotionDisplayScreenState extends State<EmotionDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    final SongsController songCon = SongsController();
    final String description = widget.emotion; // Access widget.emotion here

    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomSliverBar(
            title: description,
          ),
          SliverFillRemaining(
            child: FutureBuilder<List<SongModel>>(
              future: songCon.getEmotionSongs(description),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final descriptionSongs = snapshot.data!;

                  // Limit the length of the list to 5
                  final limitedSongs = descriptionSongs.length > 5
                      ? descriptionSongs.sublist(0, 5)
                      : descriptionSongs;

                  // Randomize the songs
                  final random = Random();
                  limitedSongs.shuffle(random);

                  return limitedSongs.isEmpty
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
                          itemCount: limitedSongs.length,
                          itemBuilder: (context, index) {
                            final song = limitedSongs[index];
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
