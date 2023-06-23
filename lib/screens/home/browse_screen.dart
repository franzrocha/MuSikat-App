import 'package:musikat_app/screens/home/categories/genres_screen.dart';
import 'package:musikat_app/screens/home/categories/language_screen.dart';
import 'package:musikat_app/screens/home/categories/mood_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/widgets/search_bar.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          
          children: [
            Searchbar(),

       Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 10),
            child: Container(
              padding: const EdgeInsets.only(top: 25),
              child: Text(
                'Categories to explore',
                textAlign: TextAlign.right,
                style: sloganStyle,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 10),
                child: Row(
                  children: [
                    CategoryCard(image: genrePic, text: 'Genres', onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GenresScreen(),
                        ),
                      );
                    },),
                    CategoryCard(image: languagePic, text: 'Languages', onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguagesScreen(),
                        ),
                      );

                    },),
                    CategoryCard(image: moodPic, text: 'Moods', 
                  
                      onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoodsScreen(),
                        ),
                      );
                    },),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
          ],
        ),
      ),
    );
  }
}