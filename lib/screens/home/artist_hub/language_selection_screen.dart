import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<String> _languages = [
    'English',
    'Tagalog',
  ];

  final Map<String, bool> _checkedLanguages = {};

  @override
  void initState() {
    super.initState();
    for (String language in _languages) {
      _checkedLanguages[language] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: appbar(context),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (BuildContext context, int index) {
          String language = _languages[index];
          return CheckboxListTile(
            activeColor: musikatColor2,
            selectedTileColor: Colors.grey,
            title: Text(
              language,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            ),
            value: _checkedLanguages[language],
            onChanged: (bool? value) {
              setState(() {
                _checkedLanguages[language] = value!;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          List<String> selectedLanguages = [];
          for (String language in _languages) {
            if (_checkedLanguages[language]!) {
              selectedLanguages.add(language);
            }
          }
          Navigator.pop(context, selectedLanguages);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text("Select a language",
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
}
