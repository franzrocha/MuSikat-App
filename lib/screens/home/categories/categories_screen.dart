import 'package:musikat_app/screens/home/categories/genres_screen.dart';
import 'package:musikat_app/screens/home/categories/language_screen.dart';
import 'package:musikat_app/screens/home/categories/mood_screen.dart';
import 'package:musikat_app/utils/exports.dart';

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
          'Categories',
          style: appBarStyle,
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                CategoryCard(
                  image: genrePic,
                  text: 'genres',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenresScreen(),
                      ),
                    );
                  },
                ),
                CategoryCard(
                  image: languagePic,
                  text: 'languages',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguagesScreen(),
                      ),
                    );
                  },
                ),
                CategoryCard(
                  image: moodPic,
                  text: 'moods',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
