// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongBottomField extends StatefulWidget {
  final String songId;
  const SongBottomField({
    super.key,
    required this.songId,
  });

  @override
  State<SongBottomField> createState() => _SongBottomFieldState();
}

class _SongBottomFieldState extends State<SongBottomField> {
  final SongsController _songCon = SongsController();
  bool _isLiked = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadIsLiked();
  }

  void _loadIsLiked() async {
    _prefs = await SharedPreferences.getInstance();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      _isLiked = _prefs.getBool(uid + widget.songId) ?? false;
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
              ListTile(
                leading: FaIcon(
                  _isLiked
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
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
                  await _prefs.setBool(uid + widget.songId, _isLiked);
                  if (_isLiked) {
                    // Add song to liked songs
                    await _songCon.addToLikedSongs(widget.songId);
                    ToastMessage.show(context, 'Song added to liked songs');
                  } else {
                    // Remove song from liked songs
                    await _songCon.removeLikedSong(widget.songId);
                    ToastMessage.show(context, 'Song removed from liked songs');
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.playlist_add,
                  color: Colors.white,
                ),
                title: Text(
                  "Add to playlist",
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                title: Text(
                  "View song info",
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                title: Text(
                  "Edit",
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                ),
                onTap: () {},
              ),
              ListTile(
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
                                style: GoogleFonts.inter(
                                    fontSize: 15, color: Colors.white),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        await _songCon
                                            .deleteSong(widget.songId);

                                        Navigator.of(context).pop();
                                        ToastMessage.show(context,
                                            'Song deleted successfully');
                                      } catch (e) {
                                        ToastMessage.show(
                                            context, 'Error deleting song');
                                      }
                                    },
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 255, 105, 105)),
                                    ),
                                    child: Text(
                                      "Delete",
                                      style:
                                          GoogleFonts.inter(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.inter(
                                          color: Colors.white),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
