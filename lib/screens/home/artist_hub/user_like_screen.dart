import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';

import 'package:musikat_app/utils/exports.dart';

import '../../../models/song_model.dart';

class UserLikeScreen extends StatefulWidget {
  const UserLikeScreen({Key? key}) : super(key: key);

  @override
  State<UserLikeScreen> createState() => _UserLikesScreenState();
}

class _UserLikesScreenState extends State<UserLikeScreen> {
  final LikedSongsController _likedsongCon = LikedSongsController();
  final SongsController _songCon = SongsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(context),
        backgroundColor: musikatBackgroundColor,
        body: Center(
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
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          // final likesCount = _likedsongCon.countLikedSongs();

                          return ListTile(
                            title: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              song.artist,
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
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
                            trailing: Text(
                              song.likeCount.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      );
              }
            },
          ),
        ));
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      centerTitle: true,
      title: Text("Songs Likes",
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const FaIcon(
          FontAwesomeIcons.angleLeft,
          size: 20,
        ),
      ),
    );
  }
}
