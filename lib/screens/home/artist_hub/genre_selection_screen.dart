import 'package:musikat_app/utils/exports.dart';

import 'package:musikat_app/controllers/categories_controller.dart';


class GenreSelectionScreen extends StatefulWidget {
  const GenreSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  String? selectedGenre;
  final CategoriesController _categoriesCon = CategoriesController();
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    List<String> genres = await _categoriesCon.getGenres();
    setState(() {
      if (genres.isNotEmpty) {
        selectedGenre = genres.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Select a genre', style: appBarStyle),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: Column(
        children: [
          searchBar(),
          genreList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          if (selectedGenre == null) {
            ToastMessage.show(context, 'Please select a genre');
          } else {
            Navigator.pop(context, selectedGenre);
          }
        },
        child: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Expanded genreList() {
    return Expanded(
      child: ListView.builder(
        itemCount: genres.length,
        itemBuilder: (BuildContext context, int index) {
          String genre = genres[index];
          if (searchText.isNotEmpty && !genre.toLowerCase().contains(searchText)) {
            return const SizedBox.shrink();
          }
          return Container(
            color: genre == selectedGenre ? Colors.grey : null,
            child: ListTile(
              onTap: () {
                setState(() {
                  selectedGenre = genre;
                });
              },
              selected: genre == selectedGenre,
              title: Text(
                genre,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              ),
              trailing: genre == selectedGenre
                  ? const Icon(Icons.check, color: musikatColor2)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Padding searchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          fillColor: musikatBackgroundColor,
          hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
          filled: true,
        ),
        onChanged: (value) {
          setState(() {
            searchText = value.toLowerCase();
          });
        },
      ),
    );
  }
}
