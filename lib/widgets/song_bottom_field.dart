// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/screens/home/artist_hub/edit_metadata_screen.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/widgets/owned_playlist.dart';

class SongBottomField extends StatefulWidget {
  final SongModel song;
  PlaylistModel? playlist;
  bool? hideRemoveToPlaylist;
  bool? hideEdit;
  bool? hideDelete;
  bool? hideLike;

  SongBottomField({
    super.key,
    required this.song,
    this.playlist,
    this.hideRemoveToPlaylist,
    this.hideDelete,
    this.hideEdit,
    required this.hideLike,
  });

  @override
  State<SongBottomField> createState() => _SongBottomFieldState();
}

class _SongBottomFieldState extends State<SongBottomField> {
  final SongsController _songCon = SongsController();
  final LikedSongsController _likedCon = LikedSongsController();
  final PlaylistController _playlistCon = PlaylistController();
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    checkIfSongIsLiked();
  }

  void checkIfSongIsLiked() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    bool isLiked = await _likedCon.isSongLikedByUser(widget.song.songId, uid);
    setState(() {
      _isLiked = isLiked;
    });
  }

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
              addToPlaylist(context),
              viewSongInfo(),
              Visibility(
                visible: widget.hideLike == true ? false : true,
                child: likeSong(context),
              ),
              if (widget.playlist?.uid ==
                  FirebaseAuth.instance.currentUser?.uid) ...{
                Visibility(
                  visible: widget.hideRemoveToPlaylist == true ? false : true,
                  child: removeSongFromPlaylist(context),
                ),
              },
              if (FirebaseAuth.instance.currentUser != null &&
                  widget.song.uid ==
                      FirebaseAuth.instance.currentUser!.uid) ...[
                Visibility(
                  visible: widget.hideEdit == true ? false : true,
                  child: editSong(),
                ),
                Visibility(
                  visible: widget.hideEdit == true ? false : true,
                  child: deleteSong(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  ListTile removeSongFromPlaylist(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.remove_circle_outline,
        color: Colors.white,
      ),
      title: Text(
        "Remove song from playlist",
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      onTap: () async {
        try {
          await _playlistCon.removeSongFromPlaylist(
              widget.playlist!.playlistId, widget.song.songId);

          Navigator.of(context).pop();

          ToastMessage.show(context, 'Removed from playlist');
        } catch (e) {
          ToastMessage.show(context, 'Error removing song');
        }
      },
    );
  }

  ListTile deleteSong(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
      title: Text(
        "Delete",
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.of(context).pop();
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
                      "Are you sure you want to delete this song?",
                      style:
                          GoogleFonts.inter(fontSize: 12, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await _songCon.deleteSong(widget.song.songId);

                              Navigator.of(context).pop();
                              ToastMessage.show(
                                  context, 'Song deleted successfully');
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

  ListTile editSong() {
    return ListTile(
      leading: const Icon(
        Icons.edit,
        color: Colors.white,
      ),
      title: Text(
        "Edit",
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditMetadataScreen(songs: widget.song)),
        );
      },
    );
  }

  // ListTile addToQueue() {
  //   return ListTile(
  //     leading: const Icon(
  //       Icons.info,
  //       color: Colors.white,
  //     ),
  //     title: Text(
  //       "Add to queue",
  //       style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
  //     ),
  //     onTap: () {
  //      locator<MusicHandler>().addToQueue(widget.song);
  //       Navigator.pop(context);
  //     },
  //   );
  // }

  ListTile viewSongInfo() {
    return ListTile(
      leading: const Icon(
        Icons.info,
        color: Colors.white,
      ),
      title: Text(
        "View song info",
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
              child: ViewSongInfo(song: widget.song)),
        );
      },
    );
  }

  ListTile addToPlaylist(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.playlist_add,
        color: Colors.white,
      ),
      title: Text(
        "Add to playlist",
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: musikatColor4,
              child: OwnedPlaylist(
                playlistCon: _playlistCon,
                songId: widget.song.songId,
              )),
        );
      },
    );
  }

  ListTile likeSong(BuildContext context) {
    return ListTile(
      leading: FaIcon(
        _isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
        color: _isLiked ? Colors.red : Colors.white,
      ),
      title: Text(
        _isLiked ? "Remove Like" : "Like",
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      onTap: () async {
        setState(() {
          _isLiked = !_isLiked;
        });
        String uid = FirebaseAuth.instance.currentUser!.uid;
        if (_isLiked) {
          await _likedCon.addLikedSong(
            uid,
            widget.song.songId,
          );
          await FirebaseFirestore.instance
              .collection('songs')
              .doc(widget.song.songId)
              .update({'likeCount': FieldValue.increment(1)});

          ToastMessage.show(context, 'Song added to liked songs');
        } else {
          await _likedCon.removeLikedSong(
            uid,
            widget.song.songId,
          );
          await FirebaseFirestore.instance
              .collection('songs')
              .doc(widget.song.songId)
              .update({'likeCount': FieldValue.increment(-1)});

          ToastMessage.show(context, 'Song removed from liked songs');
        }
      },
    );
  }
}

class ViewSongInfo extends StatefulWidget {
  const ViewSongInfo({
    super.key,
    required this.song,
  });

  final SongModel song;

  @override
  State<ViewSongInfo> createState() => _ViewSongInfoState();
}

class _ViewSongInfoState extends State<ViewSongInfo> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: NetworkImage(widget.song.albumCover),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.song.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
        ),
        Text(
          widget.song.artist,
          style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 15),
        _buildInfoRow('Released at:',
            DateFormat("MMMM d, y").format(widget.song.createdAt)),
        _buildInfoRow('Genre:', widget.song.genre),
        _buildInfoRow('Languages:', widget.song.languages.join(", ")),
        _buildInfoRow('Writers:', widget.song.writers.join(", ")),
        _buildInfoRow('Producers:', widget.song.producers.join(", ")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Wrap(
            spacing: 5,
            children: widget.song.description
                .map((e) => Chip(
                      label: Text(
                        e,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: musikatColor3,
                    ))
                .toList(),
          ),
        ),
      ],
    ));
  }
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
