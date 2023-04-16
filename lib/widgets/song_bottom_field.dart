// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/widgets/toast_msg.dart';

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
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.heart,
                  color: Colors.grey,
                ),
                title: Text(
                  "Like",
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.playlist_add,
                  color: Colors.grey,
                ),
                title: Text(
                  "Add to playlist",
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.info,
                  color: Colors.grey,
                ),
                title: Text(
                  "View song info",
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                ),
                title: Text(
                  "Edit",
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                title: Text(
                  "Delete",
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Delete",
                                style: GoogleFonts.inter(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                "Are you sure you want to delete this song?",
                                style: GoogleFonts.inter(fontSize: 15),
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
                                              255, 244, 196, 196)),
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
                                          color: Colors.black),
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
