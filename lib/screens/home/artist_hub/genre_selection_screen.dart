import 'package:musikat_app/controllers/categories_controller.dart';
import 'package:musikat_app/utils/exports.dart';

class GenreSelectionScreen extends StatefulWidget {
  const GenreSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  final Map<String, bool> _checkedGenres = {};
  final CategoriesController _categoriesCon = CategoriesController();
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  bool showNoResults = false;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    List<String> genres = await _categoriesCon.getGenres();
    setState(() {
      for (String genre in genres) {
        _checkedGenres[genre] = false;
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
          if (showNoResults) Text('No results found', style: shortDefault),
          genreList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          String selectedGenre = _checkedGenres.keys.firstWhere(
            (genre) => _checkedGenres[genre]!,
            orElse: () => '',
          );
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

  Expanded genreList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _checkedGenres.length,
        itemBuilder: (BuildContext context, int index) {
          String genre = _checkedGenres.keys.toList()[index];
          if (searchText.isNotEmpty &&
              !genre.toLowerCase().contains(searchText)) {
            return const SizedBox.shrink();
          }
          return Container(
            color: _checkedGenres[genre]! ? const Color.fromARGB(255, 10, 10, 10) : null,
            child: ListTile(
              onTap: () {
                setState(() {
                  _checkedGenres.forEach((key, value) {
                    _checkedGenres[key] = false;
                  });
                  _checkedGenres[genre] = true;
                });
              },
              selected: _checkedGenres[genre]!,
              title: Text(
                genre,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              ),
              trailing: _checkedGenres[genre]!
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
            showNoResults = _checkedGenres.keys
                .every((genre) => !genre.toLowerCase().contains(searchText));
          });
        },
      ),
    );
  }
}
