// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/screens/home/artist_hub/description_selection_screen.dart';
import 'package:musikat_app/screens/home/artist_hub/language_selection_screen.dart';
import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/utils/exports.dart';

import 'genre_selection_screen.dart';

class EditMetadataScreen extends StatefulWidget {
  const EditMetadataScreen({super.key, required this.songs});
  final SongModel songs;

  @override
  State<EditMetadataScreen> createState() => _EditMetadataScreenState();
}

class _EditMetadataScreenState extends State<EditMetadataScreen> {
  final _formKey = GlobalKey<FormState>();
  final SongsController _songCon = SongsController();
  TextEditingController? _titleCon, _writerCon, _producerCon;

  @override
  void initState() {
    super.initState();
    _titleCon = TextEditingController(text: widget.songs.title);
    _writers = List<String>.from(widget.songs.writers);
    _writerCon = TextEditingController();
    _producers = List<String>.from(widget.songs.producers);
    _producerCon = TextEditingController();
    selectedGenre = widget.songs.genre;
    selectedLanguage = widget.songs.languages;
    selectedDescription = widget.songs.description;
  }

  List<String> _writers = [];
  List<String> _producers = [];
  List<String>? selectedLanguage;
  List<String>? selectedDescription;
  String? selectedGenre;

  File? _selectedAlbumCover;

  void _editAlbumCover() async {
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

  void _editData() async {
    String title = _titleCon!.text.trim();
    List<String> trimmedWriters =
        _writers.map((writer) => writer.trim()).toList();
    List<String> trimmedProducers =
        _producers.map((producer) => producer.trim()).toList();

    final SongService songService = SongService();

    const LoadingIndicator();

    try {
      final String songId = await songService.updateSong(
          widget.songs.songId,
          title,
          _selectedAlbumCover != null
              ? _selectedAlbumCover!.path
              : null, 
          trimmedWriters,
          trimmedProducers,
          selectedGenre!,
          selectedLanguage!,
          selectedDescription!);

      final SongModel updatedSong = await _songCon.getSongById(songId);

      Navigator.of(context).pop(updatedSong);

      ToastMessage.show(context, 'Song updated successfully');
    } catch (e) {
      print('Update failed: ${e.toString()}');
      ToastMessage.show(context, 'Update failed: ${e.toString()}');
      return;
    }
  }

  void _editWriter(String writer) {
    setState(() {
      _writers.add(writer);
    });
    _writerCon!.clear();
  }

  void _editProducer(String producer) {
    setState(() {
      _producers.add(producer);
    });
    _producerCon!.clear();
  }

  @override
  void dispose() {
    _titleCon!.dispose();
    _writerCon!.dispose();
    _producerCon!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Edit Metadata',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
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
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: InkWell(
                      onTap: _editAlbumCover,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          image: _selectedAlbumCover != null
                              ? DecorationImage(
                                  image: FileImage(_selectedAlbumCover!),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      widget.songs.albumCover),
                                  fit: BoxFit.cover,
                                ),
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
                  const SizedBox(
                    height: 20,
                  ),
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
                  const SizedBox(height: 10),
                  Text(
                    'Edit genre',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  genreTile(context),
                  const SizedBox(height: 10),
                  Text(
                    'Choose language',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  languageTile(context),
                  const SizedBox(height: 10),
                  Text(
                    'Describe the track',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  descriptionTile(context),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: _editData,
        child: const Icon(Icons.upload),
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
            if (_producerCon!.text.isEmpty) {
              ToastMessage.show(
                  context, 'Please enter a producer for the song');
            } else if (_producers
                .map((w) => w.toLowerCase())
                .contains(_producerCon!.text.toLowerCase())) {
              ToastMessage.show(context, 'Producer already added');
            } else if (_producers.length < 10) {
              setState(() {
                _editProducer(_producerCon!.text);
                _producerCon!.clear();
              });
            } else {
              ToastMessage.show(context, 'You can only add up to 10 producers');
              _producerCon!.clear();
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
                                     deleteIconColor: Colors.white,

                    label: Text(writer),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.grey, // add the desired color
              width: 0.5 // add the desired width
              ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.grey,
          ),
          onPressed: () {
            if (_writerCon!.text.isEmpty) {
              ToastMessage.show(context, 'Please enter a writer for the song');
            } else if (_writers
                .map((w) => w.toLowerCase())
                .contains(_writerCon!.text.toLowerCase())) {
              ToastMessage.show(context, 'Writer already added');
            } else if (_writers.length < 10) {
              setState(() {
                _editWriter(_writerCon!.text);
                _writerCon!.clear();
              });
            } else {
              ToastMessage.show(context, 'You can only add up to 10 writers');
              _writerCon!.clear();
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
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
    );
  }
}
