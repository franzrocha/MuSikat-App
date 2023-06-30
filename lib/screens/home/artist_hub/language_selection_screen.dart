import 'package:musikat_app/controllers/categories_controller.dart';
import 'package:musikat_app/utils/exports.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final Map<String, bool> _checkedLanguages = {};
  final CategoriesController _categoriesCon = CategoriesController();
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  bool showNoResults = false;

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    List<String> languages = await _categoriesCon.getLanguages();
    setState(() {
      for (String language in languages) {
        _checkedLanguages[language] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Select a language', style: appBarStyle),
        showLogo: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                bool hasSelectedLanguages = false;
                _checkedLanguages.forEach((language, isSelected) {
                  if (isSelected) {
                    hasSelectedLanguages = true;
                    _checkedLanguages[language] = false;
                  }
                });

                if (hasSelectedLanguages) {
                  ToastMessage.show(context, 'All languages removed');
                } else {
                  ToastMessage.show(context, 'No languages selected to remove');
                }
              });
            },
            icon: const FaIcon(
              FontAwesomeIcons.trash,
              size: 20,
            ),
          ),
        ],
      ),
      backgroundColor: musikatBackgroundColor,
      body: Column(
        children: [
          searchBar(),
          languageChips(),
          if (showNoResults) Text('No results found', style: shortDefault),
          languageList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          List<String> selectedLanguages = [];
          for (String language in _checkedLanguages.keys) {
            if (_checkedLanguages[language]!) {
              selectedLanguages.add(language);
            }
          }
          if (selectedLanguages.isEmpty) {
            ToastMessage.show(context, 'Please select a language');
          } else if (selectedLanguages.length > 3) {
            ToastMessage.show(
                context, 'Please select a maximum of 3 languages');
          } else {
            Navigator.pop(context, selectedLanguages);
          }
        },
        child: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Expanded languageList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _checkedLanguages.length,
        itemBuilder: (BuildContext context, int index) {
          String language = _checkedLanguages.keys.toList()[index];
          if (searchText.isNotEmpty &&
              !language.toLowerCase().contains(searchText)) {
            return const SizedBox.shrink();
          }
          return Container(
            color: _checkedLanguages[language]!
                ? const Color.fromARGB(255, 10, 10, 10)
                : null,
            child: ListTile(
              onTap: () {
                setState(() {
                  _checkedLanguages[language] = !_checkedLanguages[language]!;
                });
              },
              selected: _checkedLanguages[language]!,
              title: Text(
                language,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              trailing: _checkedLanguages[language]!
                  ? const Icon(Icons.check, color: musikatColor2)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Padding languageChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _checkedLanguages.keys
              .where((language) => _checkedLanguages[language]!)
              .map((language) => Chip(
                    deleteIconColor: Colors.white,
                    backgroundColor: musikatColor,
                    label: Text(
                      language,
                      style:
                          GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    ),
                    onDeleted: () {
                      setState(() {
                        _checkedLanguages[language] = false;
                      });
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Padding searchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search',
          fillColor: musikatBackgroundColor,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          filled: true,
        ),
        onChanged: (value) {
          setState(() {
            searchText = value.toLowerCase();
            showNoResults = _checkedLanguages.keys.every(
                (language) => !language.toLowerCase().contains(searchText));
          });
        },
      ),
    );
  }
}
