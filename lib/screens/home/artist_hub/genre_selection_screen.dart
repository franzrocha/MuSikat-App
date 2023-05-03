import 'package:musikat_app/utils/exports.dart';

class GenreSelectionScreen extends StatefulWidget {
  const GenreSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  String selectedGenre = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        title: Text(
          'Select a genre',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      body: ListView.builder(
            physics: const BouncingScrollPhysics(),
        itemCount: genres.length,
        itemBuilder: (BuildContext context, int index) {
          String genre = genres[index];
          return ListTile(
            onTap: () {
              setState(() {
                selectedGenre = genre;
              });
            },
            selected: selectedGenre == genre,
            selectedTileColor: Colors.grey,
            title: Text(
              genre,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            ),
            trailing: selectedGenre == genre
                ? const Icon(Icons.check, color: musikatColor2)
                : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          if (selectedGenre.isEmpty) {
            ToastMessage.show(context, 'Please select a genre');
          } else {
            Navigator.pop(context, selectedGenre);
          }
        },
        child: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
