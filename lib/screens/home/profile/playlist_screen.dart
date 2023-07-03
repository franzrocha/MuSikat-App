import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/screens/home/profile/create_playlist_screen.dart';
import 'package:musikat_app/screens/home/profile/playlist_detail_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/widgets/playlist_bottom_field.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final PlaylistController _playlistCon = PlaylistController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Playlists',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        showLogo: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreatePlaylistScreen(),
                  ),
                );
              }),
        ],
      ),
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: StreamBuilder<List<PlaylistModel>>(
            stream: _playlistCon.getPlaylistStream(),
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
                final playlists = snapshot.data!
                    .where((playlist) =>
                        playlist.uid == FirebaseAuth.instance.currentUser!.uid)
                    .toList();

                return playlists.isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/no_played.png', width: 200, height: 200,),
                    Text('No playlists yet. Create a new one', style: shortDefault,),
                  ],
                )
                
                : ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];

                    return ListTile(
                        onLongPress: () {
                          showModalBottomSheet(
                              backgroundColor: musikatColor4,
                              context: context,
                              builder: (BuildContext context) {
                                return SingleChildScrollView(
                                    child: PlaylistBottomField(
                                  playlist: playlist,
                                ));
                              });
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlaylistDetailScreen(
                                playlist: playlist,
                              ),
                            ),
                          );
                        },
                        title: Text(playlist.title,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                            )),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(playlist.playlistImg),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ));
                  },
                );
              }
            }),
      ),
    );
  }
}
