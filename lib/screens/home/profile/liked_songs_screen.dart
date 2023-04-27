// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';
import 'package:musikat_app/screens/home/music_player.dart';
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
          const CustomSliverBar(
            image:
                "https://images.unsplash.com/photo-1569513586164-80529357ad6f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80",
            title: "Liked Songs",
            caption: 'All your liked songs in one place',
          ),
          SliverFillRemaining(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _likedCon.getLikedSongs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, dynamic>> likedSongs = snapshot.data!;
                  return ListView.builder(
                    itemCount: likedSongs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> songData = likedSongs[index];
                      return ListTile(
                        // onTap: () {
                        //    Navigator.of(context).push(
                        //             MaterialPageRoute(
                        //                 builder: (context) => MusicPlayerScreen(
                        //                       songs: songData['audio'],
                        //                       initialIndex:
                        //                           songData['initialIndex'],
                        //                     )),
                        //           );
                        // },
                        title: Text(
                          songData['title'],
                          style: GoogleFonts.inter(
                              fontSize: 16, color: Colors.white),
                        ),
                        subtitle: Text(
                          songData['artist'],
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
                              image: NetworkImage(songData['albumCover']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            setState(() {
                              likedSongs.removeAt(index);
                            });
                            String uid = FirebaseAuth.instance.currentUser!.uid;
                            await _likedCon.removeLikedSong(
                              uid,
                              songData['id'],
                            );
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
