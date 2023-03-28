import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/audio_uploader_screen.dart';
import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/widgets/loading_indicator.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final SongService songService = SongService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: StreamBuilder<List<SongModel>>(
          stream: songService.getSongsStream(),
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
                        // mainAxisAlignment: MainAxisAlignment.center,
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
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
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
                        return FutureBuilder<UserModel?>(
                          future: UserModel.fromUid(uid: song.uid),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              final user = snapshot.data!;
                              return ListTile(
                                title: Text(
                                  song.title,
                                  style: GoogleFonts.inter(
                                      color: Colors.white, fontSize: 16),
                                ),
                                subtitle: Text(user.username,
                                    style: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 14)),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(song.albumCover),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        );
                      },
                    );
            }
          },
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text("Library",
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      backgroundColor: const Color(0xff262525),
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
