import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/models/song_model.dart';

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
              return const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    backgroundColor: musikatColor2,
                    valueColor: AlwaysStoppedAnimation(
                      musikatColor,
                    ),
                    strokeWidth: 10,
                  ));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    backgroundColor: musikatColor2,
                    valueColor: AlwaysStoppedAnimation(
                      musikatColor,
                    ),
                    strokeWidth: 10,
                  ));
            }

            final songs = snapshot.data!;
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  title: Text(
                    song.title,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: Text(song.genre,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(song.albumCover),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const MusicPlayerScreen()),
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.genre),
                );
              },
            );
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
