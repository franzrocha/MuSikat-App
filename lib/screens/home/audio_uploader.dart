// ignore_for_file: unused_local_variable
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/models/song_model.dart';

import '../../services/song_service.dart';

class AudioUploader extends StatefulWidget {
  const AudioUploader({Key? key}) : super(key: key);

  @override
  AudioUploaderState createState() => AudioUploaderState();
}

class AudioUploaderState extends State<AudioUploader> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCon = TextEditingController();

  FirebaseStorage storage = FirebaseStorage.instance;

  File? _selectedFile;

  void _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _removeAudioFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _uploadAudio() async {
    if (_selectedFile != null) {
      final String fileName = _selectedFile!.path.split('/').last;
      final String title = _titleCon.text.trim();
      if (title.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Please enter a title for the song',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      try {
        String songId =
            await SongService().uploadSong(title, _selectedFile!.path);
        final SongModel song = await SongService().getSongById(songId);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(song);

        // Show toast message to indicate success
        Fluttertoast.showToast(
          msg: 'Song uploaded successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      } catch (e) {
        print('Upload failed: ${e.toString()}');
        Fluttertoast.showToast(
          msg: 'Upload failed: ${e.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please select an audio file to upload',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            onChanged: () {
              _formKey.currentState?.validate();
              if (mounted) {
                setState(() {});
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                titleForm(),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickAudioFile,
                      icon: Icon(_selectedFile != null
                          ? Icons.check_circle
                          : Icons.music_note),
                      label: Text(_selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : 'Select Audio'),
                    ),
                    if (_selectedFile != null)
                      InkWell(
                        onTap: _removeAudioFile,
                        borderRadius: BorderRadius.circular(20.0),
                        splashColor: Colors.grey[300]!,
                        hoverColor: Colors.grey[200]!,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                Container(
                  width: 250,
                  height: 60,
                  decoration: BoxDecoration(
                      color: const Color(0xfffca311),
                      borderRadius: BorderRadius.circular(60)),
                  child: TextButton(
                    onPressed: _uploadAudio,
                    child: Text(
                      'Upload',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding titleForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        style: GoogleFonts.inter(
          color: Colors.black,
          fontSize: 17,
        ),
        controller: _titleCon,
        validator: (value) {
          if (value!.isEmpty) {
            return null;
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Enter the song title',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.music_note),
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text("Upload",
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
