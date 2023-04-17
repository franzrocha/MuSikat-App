import 'package:musikat_app/utils/ui_exports.dart';
import 'package:musikat_app/utils/widgets_export.dart';

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
      appBar: appbar(context),
      body: ListView.builder(
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

AppBar appbar(BuildContext context) {
  return AppBar(
    toolbarHeight: 75,
    title: Text("Select a genre",
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
