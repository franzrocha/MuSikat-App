import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/screens/home/artist_hub/audio_uploader_screen.dart';
import 'package:musikat_app/utils/exports.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final SongsController _songCon = SongsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(slivers: [
        CustomSliverBar(
          image: libraryPic,
          title: 'Library',
          caption: 'All the music you uploaded.',
        ),
        SliverFillRemaining(
          child: Center(
            child: StreamBuilder<List<SongModel>>(
              stream: _songCon.getSongsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const LoadingIndicator();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else {
                  final songs = snapshot.data!
                      .where((song) =>
                          song.uid == FirebaseAuth.instance.currentUser?.uid)
                      .toList();

                  return songs.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 70),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25),
                                child: Image.asset("assets/images/no_music.png",
                                    width: 230, height: 230),
                              ),
                              Text(
                                "No songs found in your library",
                                style: shortThinStyle,
                              ),
                              const SizedBox(height: 40),
                              Container(
                                width: 200,
                                height: 63,
                                decoration: BoxDecoration(
                                    color: musikatColor,
                                    borderRadius: BorderRadius.circular(60)),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AudioUploaderScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Upload a file',
                                    style: buttonStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];

                            return ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => MusicPlayerScreen(
                                          songs: songs,
                                          initialIndex: index,
                                        )),
                              ),
                              onLongPress: () {
                                showModalBottomSheet(
                                    backgroundColor: musikatColor4,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                        child: SongBottomField(
                                          song: song,
                                          hideRemoveToPlaylist: true,
                                           hideLike: false,
                                        ),
                                      );
                                    });
                              },
                              title: Text(song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: songTitle),
                              subtitle: Text(song.artist, style: songArtist),
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
                            );
                          });
                }
              },
            ),
          ),
        ),
      ]),
    );
  }
}
