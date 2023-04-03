import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/widgets/category_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: const [
              CategoryCard(
                image: 'assets/images/category/genres.jpg',
                text: 'genres',
              ),
              CategoryCard(
                image: 'assets/images/category/languages.jpg',
                text: 'languages',
              ),
              CategoryCard(
                image: 'assets/images/category/mood.jpg',
                text: 'moods',
              ),
            ],
          ),
        ),
      )),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text(
        "Categories",
        textAlign: TextAlign.right,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
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
