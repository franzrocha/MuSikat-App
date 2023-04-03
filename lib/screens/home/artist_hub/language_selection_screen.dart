import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/utils/list_values.dart';
import 'package:musikat_app/widgets/toast_msg.dart';

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
      appBar: appbar(context),
      body: ListView.builder(
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
