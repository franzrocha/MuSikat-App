import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/utils/exports.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({Key? key, required this.image, required this.text, this.onTap})
      : super(key: key);

  final String image;
  final String text;
  final Function()? onTap;

 @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Card(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: 175,
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(image),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  text,
                  style: appBarStyle.copyWith(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}