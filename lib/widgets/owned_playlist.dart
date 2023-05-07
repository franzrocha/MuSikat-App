// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/screens/home/profile/create_playlist_screen.dart';
import 'package:musikat_app/utils/exports.dart';

class OwnedPlaylist extends StatefulWidget {
  const OwnedPlaylist({
    super.key,
    required PlaylistController playlistCon,
    required this.songId,
  }) : _playlistCon = playlistCon;

  final PlaylistController _playlistCon;
  final String songId;

  @override
  State<OwnedPlaylist> createState() => _OwnedPlaylistState();
}

class _OwnedPlaylistState extends State<OwnedPlaylist> {
  final PlaylistController _playlistCon = PlaylistController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<List<PlaylistModel>>(
          stream: widget._playlistCon.getPlaylistStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container();
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              final playlists = snapshot.data!
                  .where((playlist) =>
                      playlist.uid == FirebaseAuth.instance.currentUser!.uid)
                  .toList();

              return Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 43,
                    decoration: BoxDecoration(
                        color: musikatColor,
                        borderRadius: BorderRadius.circular(60)),
                    child: TextButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreatePlaylistScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Create Playlist',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];

                      return ListTile(
                          title: Text(playlist.title,
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 12)),
                          onTap: () async {
                            try {
                              await _playlistCon.addSongToPlaylist(
                                  playlist.playlistId, widget.songId);
                              Navigator.pop(context, true);
                              ToastMessage.show(
                                  context, 'Song added to playlist');
                            } catch (e) {
                              ToastMessage.show(
                                  context, 'Failed to add song to playlist');
                            }
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    playlist.playlistImg),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ));
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }
          }),
    );
  }
}
