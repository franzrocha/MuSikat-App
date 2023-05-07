// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
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
            children: [
              const SizedBox(height: 20),
              FutureBuilder<UserModel>(
                future:
                    _playlistCon.getUserForPlaylist(widget.playlist.playlistId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white24,
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    UserModel user = snapshot.data!;
                    return Row(
                      children: [
                        AvatarImage(uid: user.uid, radius: 12),
                        const SizedBox(width: 5),
                        Text(user.username,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white)),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
          SliverFillRemaining(
            child: FutureBuilder<List<SongModel>>(
              future:
                  _playlistCon.getSongsForPlaylist(widget.playlist.playlistId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<SongModel> songs = snapshot.data!;

                  return songs.isEmpty
                      ? Center(
                          child: Text(
                          'No songs in your playlist for now.',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ))
                      : ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            SongModel song = songs[index];

                            return ListTile(
                              onLongPress: () {
                                showModalBottomSheet(
                                    backgroundColor: musikatColor4,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: SafeArea(
                                            top: false,
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SongBottomField(
                                                    song: song,
                                                    hideEdit: true,
                                                    hideDelete: true,
                                                    hideAddtoPlaylist: true,
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      color: Colors.white,
                                                    ),
                                                    title: Text(
                                                      "Remove song from playlist",
                                                      style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                    ),
                                                    onTap: () async {
                                                      try {
                                                        await _playlistCon
                                                            .removeSongFromPlaylist(
                                                                widget.playlist
                                                                    .playlistId,
                                                                song.songId);

                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          songs.removeAt(index);
                                                        });

                                                        ToastMessage.show(
                                                            context,
                                                            'Removed from playlist');
                                                      } catch (e) {
                                                        ToastMessage.show(
                                                            context,
                                                            'Error removing song');
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              title: Text(
                                song.title.length > 35
                                    ? '${song.title.substring(0, 35)}..'
                                    : song.title,
                                style: GoogleFonts.inter(
                                    fontSize: 16, color: Colors.white),
                                maxLines: 1,
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
                                    image: CachedNetworkImageProvider(
                                        song.albumCover),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              onTap: () {
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
