// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:musikat_app/services/playlist_service.dart';
import 'package:musikat_app/utils/exports.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCon = TextEditingController(),
      _descriptionCon = TextEditingController();

  File? _selectedPlaylistCover;

  void _pickPlaylistCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedPlaylistCover = File(result.files.single.path!);
      });
    } else {
      ToastMessage.show(context, 'No image selected');
    }
  }

  void _onCreatePlaylist() async {
    await PlaylistService.createPlaylist(
        context, _titleCon, _descriptionCon, _selectedPlaylistCover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        title: Text(
          'Create Playlist',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
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
                      onTap: _pickPlaylistCover,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          image: _selectedPlaylistCover != null
                              ? DecorationImage(
                                  image: FileImage(_selectedPlaylistCover!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        width: 180,
                        height: 170,
                        child: _selectedPlaylistCover == null
                            ? const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    'Title',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  titleForm(),
                  const SizedBox(height: 30),
                  Text(
                    'Description',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  descriptionForm(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: _onCreatePlaylist,
        child: const Icon(Icons.create),
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

  TextFormField descriptionForm() {
    return TextFormField(
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 13,
      ),
      controller: _descriptionCon,
      maxLength: 50,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        hintText: 'Add an optional description.',
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
        counterStyle: GoogleFonts.inter(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }
}
