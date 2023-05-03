// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  final LikedSongsController _likedCon = LikedSongsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomSliverBar(
            image: likedSongsPic,
            title: "Liked Songs",
            caption: 'All your liked songs in one place.',
          ),
          SliverFillRemaining(
           
              child: FutureBuilder<List<SongModel>>(
                future: _likedCon.getLikedSongs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: LoadingIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<SongModel> likedSongs = snapshot.data!;
            
                    return likedSongs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 70),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Image.asset("assets/images/no_music.png",
                                      width: 230, height: 230),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No liked songs yet",
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: likedSongs.length,
                            itemBuilder: (context, index) {
                              SongModel songData = likedSongs[index];
                              return ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => MusicPlayerScreen(
                                              songs: likedSongs,
                                              initialIndex: index,
                                            )),
                                  );
                                },
                                title: Text(
                                  songData.title.length > 35
                                      ? '${songData.title.substring(0, 35)}..'
                                      : songData.title,
                                  style: GoogleFonts.inter(
                                      fontSize: 16, color: Colors.white),
                                ),
                                subtitle: Text(
                                  songData.artist,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(songData.albumCover),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    String uid =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    await _likedCon.removeLikedSong(
                                      uid,
                                      songData.songId,
                                    );
                                    setState(() {
                                      likedSongs.removeAt(index);
                                    });
                                    ToastMessage.show(
                                        context, 'Song removed from liked songs');
                                  },
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),
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
