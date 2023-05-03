import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});

  final PlaylistModel playlist;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistController _playlistCon = PlaylistController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomSliverBar(
            image: widget.playlist.playlistImg,
            title: widget.playlist.title,
            caption: widget.playlist.description,
          
          ),
        
          SliverFillRemaining(
            child: FutureBuilder<List<SongModel>>(
              future:
                  _playlistCon.getSongsForPlaylist(widget.playlist.playlistId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<SongModel> songs = snapshot.data!;
                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      SongModel song = songs[index];

                      return ListTile(
                        title: Text(
                          song.title.length > 35
                              ? '${song.title.substring(0, 35)}..'
                              : song.title,
                          style: GoogleFonts.inter(
                              fontSize: 16, color: Colors.white),
                        ),
                        subtitle: Text(
                          song.artist,
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
                              image:
                                  CachedNetworkImageProvider(song.albumCover),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        onTap: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MusicPlayerScreen(
                                songs: songs,
                                initialIndex: index,
                              ),
                            ),
                          );
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
