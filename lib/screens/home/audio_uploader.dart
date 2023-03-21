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
  final TextEditingController _titleCon = TextEditingController(),
      _writerCon = TextEditingController(),
      _producerCon = TextEditingController();
  final List<String> _writers = [];
  final List<String> _producers = [];

  FirebaseStorage storage = FirebaseStorage.instance;

  File? _selectedFile, _selectedAlbumCover;

  void _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      ToastMessage.show(context, 'No audio selected');
    }
  }

  void _pickAlbumCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedAlbumCover = File(result.files.single.path!);
      });
    } else {
      ToastMessage.show(context, 'No image selected');
    }
  }

  void _removeAudioFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _addWriter(String writer) {
    setState(() {
      _writers.add(writer);
    });
    _writerCon.clear();
  }

  void _addProducer(String producer) {
    setState(() {
      _producers.add(producer);
    });
    _producerCon.clear();
  }

  void _uploadAudio() async {
    if (_selectedFile == null || _selectedAlbumCover == null) {
      if (_selectedFile == null && _selectedAlbumCover == null) {
        ToastMessage.show(context, 'Please input the required fields');
      } else if (_selectedFile == null) {
        ToastMessage.show(context, 'Please select an audio file');
      } else {
        ToastMessage.show(context, 'Please select an album cover');
      }
      return;
    }

    final String fileName = _selectedFile!.path.split('/').last;
    final String title = _titleCon.text.trim();
    final String genre = genreValue.trim();
    final List<String> trimmedWriters =
        _writers.map((writer) => writer.trim()).toList();
    final List<String> trimmedProducers =
        _producers.map((producer) => producer.trim()).toList();

    if (title.isEmpty) {
      ToastMessage.show(context, 'Please enter the title of the song');
      return;
    }

    if (trimmedWriters.isEmpty) {
      ToastMessage.show(context, 'Please add songwriter(s) of the song');
      return;
    }

    if (trimmedProducers.isEmpty) {
      ToastMessage.show(context, 'Please add producer(s) of the song');
      return;
    }

    final SongService songService = SongService();

    // Show progress during upload
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Uploading...",
            style: GoogleFonts.inter(fontSize: 18),
          ),
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
      final String songId = await songService.uploadSong(
          title,
          _selectedFile!.path,
          _selectedAlbumCover!.path,
          trimmedWriters,
          trimmedProducers, genre);

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
  }

  @override
  void dispose() {
    _titleCon.dispose();
    _writerCon.dispose();
    _producerCon.dispose();
    super.dispose();
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
                        width: 180,
                        height: 170,
                        child: _selectedAlbumCover == null
                            ? const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickAudioFile,
                            icon: Icon(_selectedFile != null
                                ? Icons.check_circle
                                : Icons.music_note),
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedFile != null
                                      ? _selectedFile!.path.split('/').last
                                      : 'Select Audio',
                                ),
                                if (_selectedFile != null)
                                  const SizedBox(width: 20.0),
                              ],
                            ),
                          ),
                          if (_selectedFile != null)
                            Positioned(
                              top: 5,
                              right: 0,
                              child: InkWell(
                                onTap: _removeAudioFile,
                                borderRadius: BorderRadius.circular(20.0),
                                splashColor: Colors.grey[300]!,
                                hoverColor: Colors.grey[200]!,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Title',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  titleForm(),
                  const SizedBox(height: 20),
                  Text(
                    'Songwriter(s)',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  writerForm(),
                  const SizedBox(height: 10),
                  writerChips(),
                  const SizedBox(height: 10),
                  Text(
                    'Producer(s)',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  producerForm(),
                  const SizedBox(height: 10),
                  producerChips(),
                  genderDropDown(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DropdownButtonFormField genderDropDown(BuildContext context) {
    return DropdownButtonFormField(
      value: genreValue,
      icon: const Icon(Icons.arrow_drop_down),
      style: GoogleFonts.inter(color: Colors.white),
      decoration: const InputDecoration(
        labelStyle: TextStyle(color: Colors.white, fontSize: 18),
        labelText: "Genre",
        border: InputBorder.none,
        prefixIconConstraints: BoxConstraints(
          minWidth: 2,
        ),
      ),
      dropdownColor: Colors.black,
       itemHeight: 70, 
       isExpanded: true,
      items: genreList.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.inter(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (dynamic newValue) {
        setState(() {
          genreValue = newValue as String;
        });
      },
    );
  }

  TextFormField producerForm() {
    return TextFormField(
      controller: _producerCon,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: 'Enter the producer(s)',
        hintStyle: GoogleFonts.inter(
          color: Colors.grey,
          fontSize: 13,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (_producerCon.text.isEmpty) {
              ToastMessage.show(
                  context, 'Please enter a producer for the song');
            } else if (_producers
                .map((w) => w.toLowerCase())
                .contains(_producerCon.text.toLowerCase())) {
              ToastMessage.show(context, 'Producer already added');
            } else if (_producers.length < 10) {
              setState(() {
                _addProducer(_producerCon.text);
                _producerCon.clear();
              });
            } else {
              ToastMessage.show(context, 'You can only add up to 10 producers');
              _producerCon.clear();
            }
          },
        ),
      ),
    );
  }

  Container producerChips() {
    return Container(
      width: 450,
      height: _producers.isEmpty ? 0 : null,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _producers.map((producer) {
                  return Chip(
                    backgroundColor: musikatColor,
                    label: Text(producer),
                    labelStyle: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    deleteIcon: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _producers.remove(producer);
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Container writerChips() {
    return Container(
      width: 450,
      height: _writers.isEmpty ? 0 : null,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _writers.map((writer) {
                  return Chip(
                    backgroundColor: musikatColor,
                    label: Text(writer),
                    labelStyle: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    deleteIcon: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _writers.remove(writer);
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  TextFormField writerForm() {
    return TextFormField(
      controller: _writerCon,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: 'Enter the songwriter(s)',
        hintStyle: GoogleFonts.inter(
          color: Colors.grey,
          fontSize: 13,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (_writerCon.text.isEmpty) {
              ToastMessage.show(context, 'Please enter a writer for the song');
            } else if (_writers
                .map((w) => w.toLowerCase())
                .contains(_writerCon.text.toLowerCase())) {
              ToastMessage.show(context, 'Writer already added');
            } else if (_writers.length < 10) {
              setState(() {
                _addWriter(_writerCon.text);
                _writerCon.clear();
              });
            } else {
              ToastMessage.show(context, 'You can only add up to 10 writers');
              _writerCon.clear();
            }
          },
        ),
      ),
    );
  }

  TextFormField titleForm() {
    return TextFormField(
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 13,
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
        hintText: 'Enter the song title',
        hintStyle: GoogleFonts.inter(
          color: Colors.grey,
          fontSize: 13,
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
