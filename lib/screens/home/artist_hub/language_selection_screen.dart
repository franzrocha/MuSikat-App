import 'package:musikat_app/utils/exports.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final Map<String, bool> _checkedLanguages = {};

  @override
  void initState() {
    super.initState();
    for (String language in languages) {
      _checkedLanguages[language] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        title: Text(
          'Select a language',
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
        itemCount: languages.length,
        itemBuilder: (BuildContext context, int index) {
          String language = languages[index];
          return ListTile(
            onTap: () {
              setState(() {
                _checkedLanguages[language] = !_checkedLanguages[language]!;
              });
            },
            selected: _checkedLanguages[language]!,
            selectedTileColor: Colors.grey,
            title: Text(
              language,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            ),
            trailing: _checkedLanguages[language]!
                ? const Icon(Icons.check, color: musikatColor2)
                : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          List<String> selectedLanguages = [];
          for (String language in languages) {
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
}
