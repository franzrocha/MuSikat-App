// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/models/song_model.dart';
import '../../services/song_service.dart';
import '../../widgets/toast_msg.dart';

class AudioUploader extends StatefulWidget {
  const AudioUploader({Key? key}) : super(key: key);

  @override
  AudioUploaderState createState() => AudioUploaderState();
}

class AudioUploaderState extends State<AudioUploader> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCon = TextEditingController();

  FirebaseStorage storage = FirebaseStorage.instance;

  File? _selectedFile, _selectedAlbumCover;

  @override
  void dispose() {
    _titleCon.dispose();
    super.dispose();
  }

  void _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _pickAlbumCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedAlbumCover = File(result.files.single.path!);
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
        ToastMessage.show(context, 'Please enter the title of the song');
        return;
      }

      final SongService songService = SongService();

      // Show progress during upload
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Uploading...",
          style: GoogleFonts.inter( fontSize: 18
              )),
            content: StreamBuilder<double>(
              stream: songService.uploadProgressStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                } else {
                  final double uploadPercent = snapshot.data!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: uploadPercent / 100,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 10.0),
                      Text('${uploadPercent.toStringAsFixed(0)}% uploaded'),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          songService.cancelUpload();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                }
              },
            ),
          );
        },
      );

      try {
        // Start uploading the file
        final String songId =
            await songService.uploadSong(title, _selectedFile!.path);

        // Get the song model with the uploaded file data
        final SongModel song = await songService.getSongById(songId);

        // Close progress dialog
        Navigator.of(context).pop();

        // Navigate to the previous screen and pass the song data
        Navigator.of(context).pop(song);

        // Show toast message to indicate success
        ToastMessage.show(context, 'Song uploaded successfully');
      } catch (e) {
        print('Upload failed: ${e.toString()}');
        ToastMessage.show(context, 'Upload failed: ${e.toString()}');
        return;
      }
    } else {
      ToastMessage.show(context, 'Please select an audio file to upload');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              onChanged: () {
                _formKey.currentState?.validate();
                if (mounted) {
                  setState(() {});
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: InkWell(
                      onTap: _pickAlbumCover,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          image: _selectedAlbumCover != null
                              ? DecorationImage(
                                  image: FileImage(_selectedAlbumCover!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        width: 198,
                        height: 189,
                        child: _selectedAlbumCover == null
                            ? const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  titleForm(),
                  const SizedBox(height: 20),
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
                ],
              ),
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
          fontSize: 15,
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
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    width: 50,
                    // height: 10,
                    decoration: BoxDecoration(
                        color: const Color(0xfffca311),
                        borderRadius: BorderRadius.circular(15)),
                    child: IconButton(
                      onPressed: _uploadAudio,
                      icon: const Icon(
                        Icons.upload,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}