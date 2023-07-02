// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/screens/home/artist_hub/description_selection_screen.dart';
import 'package:musikat_app/screens/home/artist_hub/genre_selection_screen.dart';
import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/language_selection_screen.dart';
import 'package:musikat_app/utils/exports.dart';

class AudioUploaderScreen extends StatefulWidget {
  const AudioUploaderScreen({Key? key}) : super(key: key);

  @override
  AudioUploaderScreenState createState() => AudioUploaderScreenState();
}

class AudioUploaderScreenState extends State<AudioUploaderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCon = TextEditingController(),
      _writerCon = TextEditingController(),
      _producerCon = TextEditingController();

  final SongsController _songCon = SongsController();

  final List<String> _writers = [];
  final List<String> _producers = [];
  List<String>? selectedLanguage;
  List<String>? selectedDescription;
  String? selectedGenre;

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
      final cropResult = await ImageCropper().cropImage(
        sourcePath: result.files.single.path!,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 300,
        maxHeight: 300,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop album cover',
              toolbarColor: musikatBackgroundColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
        ],
      );
      if (cropResult != null) {
        setState(() {
          _selectedAlbumCover = File(cropResult.path);
        });
      } else {
        ToastMessage.show(context, 'No image selected');
      }
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

    if (selectedLanguage == null) {
      ToastMessage.show(context, 'Please select the language of the song');
      return;
    }

    if (selectedGenre == null) {
      ToastMessage.show(context, 'Please select the genre of the song');
      return;
    }

    if (selectedDescription == null) {
      ToastMessage.show(context, 'Please select the description of the song');
      return;
    }

    final SongService songService = SongService();

    // shows progress during upload
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return UploadDialog(songService: songService);
      },
    );

    try {
      final UserModel? user = await UserModel.getCurrentUser();

      // starts uploading the file
      final String songId = await songService.uploadSong(
        title,
        user!.username,
        _selectedFile!.path,
        _selectedAlbumCover!.path,
        trimmedWriters,
        trimmedProducers,
        selectedGenre!,
        user.uid,
        selectedLanguage ?? [],
        selectedDescription ?? [],
      );

      // Get the song model with the uploaded file data
      final SongModel song = await _songCon.getSongById(songId);

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
      appBar: CustomAppBar(
        title: Text(
          'Upload',
          style: appBarStyle,
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                                      ? '${_selectedFile!.path.split('/').last.substring(0, 20)}...'
                                      : 'Select Audio',
                                  overflow: TextOverflow.ellipsis,
                                  style: shortThinStyle,
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
                  Text('Title', style: shortThinStyle),
                  titleForm(),
                  const SizedBox(height: 20),
                  Text('Songwriter(s)', style: shortThinStyle),
                  const SizedBox(height: 10),
                  writerForm(),
                  const SizedBox(height: 10),
                  writerChips(),
                  const SizedBox(height: 10),
                  Text('Producer(s)', style: shortThinStyle),
                  const SizedBox(height: 10),
                  producerForm(),
                  const SizedBox(height: 10),
                  producerChips(),
                  const SizedBox(height: 10),
                  Text('Choose genre', style: shortThinStyle),
                  genreTile(context),
                  const SizedBox(height: 10),
                  Text('Choose language', style: shortThinStyle),
                  languageTile(context),
                  const SizedBox(height: 10),
                  Text('Describe the track', style: shortThinStyle),
                  descriptionTile(context),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: _uploadAudio,
        child: const Icon(Icons.upload),
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
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
    );
  }

  SizedBox descriptionTile(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListTile(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DescriptionSelectionScreen(),
            ),
          );
          if (result != null) {
            setState(() {
              selectedDescription = result;
            });
          }
        },
        title: Text(
          selectedDescription != null
              ? selectedDescription!.map((item) => '#$item').join('  ')
              : 'Describe what your track is about...',
          style: GoogleFonts.inter(
            color: selectedDescription != null ? Colors.white : Colors.grey,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 15,
        ),
      ),
    );
  }

  ListTile genreTile(BuildContext context) {
    return ListTile(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GenreSelectionScreen(),
          ),
        );
        if (result != null) {
          setState(() {
            selectedGenre = result;
          });
        }
      },
      title: Text(
        selectedGenre != null ? selectedGenre! : 'Select a genre',
        style: GoogleFonts.inter(
          color: selectedGenre != null ? Colors.white : Colors.grey,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 15,
      ),
    );
  }

  ListTile languageTile(BuildContext context) {
    return ListTile(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LanguageSelectionScreen(),
          ),
        );
        if (result != null) {
          setState(() {
            selectedLanguage = result;
          });
        }
      },
      title: Text(
        selectedLanguage != null
            ? selectedLanguage!.join(", ")
            : 'Select a language',
        style: GoogleFonts.inter(
          color: selectedLanguage != null ? Colors.white : Colors.grey,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 15,
      ),
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
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.grey,
          ),
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
                    deleteIconColor: Colors.white,
                    label: Text(producer),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
                    deleteIconColor: Colors.white,
                    label: Text(writer),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.grey,
          ),
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
}
