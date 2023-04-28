// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/screens/home/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  final LikedSongsController _likedCon = LikedSongsController();
  final AudioPlayer player = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          const CustomSliverBar(
            image:
                "https://images.unsplash.com/photo-1569513586164-80529357ad6f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80",
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
                                            //likedSongs.indexOf(songData),
                                          )),
                                );
                              },
                              title: Text(
                                songData.title,
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
                                    image: NetworkImage(songData.albumCover),
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