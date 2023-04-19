import 'package:musikat_app/screens/home/categories/genres_screen.dart';
import 'package:musikat_app/screens/home/categories/language_screen.dart';
import 'package:musikat_app/screens/home/categories/mood_screen.dart';
import 'package:musikat_app/utils/ui_exports.dart';
import 'package:musikat_app/utils/widgets_export.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Account info',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenresScreen(),
                      ),
                    );
                  },
                  child: const CategoryCard(
                    image: 'assets/images/category/genres.jpg',
                    text: 'genres',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguagesScreen(),
                      ),
                    );
                  },
                  child: const CategoryCard(
                    image: 'assets/images/category/languages.jpg',
                    text: 'languages',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodsScreen(),
                      ),
                    );
                  },
                  child: const CategoryCard(
                    image: 'assets/images/category/mood.jpg',
                    text: 'moods',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
