import 'package:musikat_app/utils/ui_exports.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({Key? key, required this.image, required this.text})
      : super(key: key);

  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          height: 175,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image:
                  DecorationImage(fit: BoxFit.cover, image: AssetImage(image))),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(text,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
