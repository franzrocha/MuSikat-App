// ignore_for_file: use_build_context_synchronously
import 'package:intl/intl.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/profile/edit_playlist_screen.dart';
import 'package:musikat_app/utils/exports.dart';

class PlaylistBottomField extends StatefulWidget {
  final PlaylistModel playlist;
  const PlaylistBottomField({super.key, required this.playlist});

  @override
  State<PlaylistBottomField> createState() => _PlaylistBottomFieldState();
}

class _PlaylistBottomFieldState extends State<PlaylistBottomField> {
  final PlaylistController _playlistCon = PlaylistController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            playlistInfo(context),
            editPlaylist(context),
            deletePlaylist(context),
          ],
        )),
      ),
    );
  }

  ListTile deletePlaylist(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
      title: Text(
        "Delete playlist",
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);

        showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: musikatColor4,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Delete",
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Are you sure you want to delete this playlist?",
                      style:
                          GoogleFonts.inter(fontSize: 15, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await _playlistCon
                                  .deletePlaylist(widget.playlist.playlistId);

                              Navigator.of(context).pop();
                              ToastMessage.show(
                                  context, 'Playlist deleted successfully');
                            } catch (e) {
                              ToastMessage.show(context, 'Error deleting song');
                            }
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 105, 105)),
                          ),
                          child: Text(
                            "Delete",
                            style: GoogleFonts.inter(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.grey.shade300),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ListTile editPlaylist(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.edit,
        color: Colors.white,
      ),
      title: Text(
        "Edit playlist",
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditPlaylistScreen(playlist: widget.playlist),
          ),
        );
      },
    );
  }

  ListTile playlistInfo(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.info,
        color: Colors.white,
      ),
      title: Text(
        "Playlist Info",
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: musikatColor4,
              child: SingleChildScrollView(
                child: FutureBuilder<UserModel>(
                  future: _playlistCon
                      .getUserForPlaylist(widget.playlist.playlistId),
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
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Created by:',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AvatarImage(uid: user.uid, radius: 12),
                              const SizedBox(width: 5),
                              Text(user.username,
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Created at:',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat("MMMM d, y")
                                .format(widget.playlist.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Songs:',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          FutureBuilder<int>(
                            future: _playlistCon
                                .getSongCount(widget.playlist.playlistId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                int songCount = snapshot.data!;
                                return Text(
                                  songCount.toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                  },
                ),
              )),
        );
      },
    );
  }
}
