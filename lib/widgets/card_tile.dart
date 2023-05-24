import 'package:musikat_app/utils/exports.dart';

class CardTile extends StatelessWidget {
  const CardTile({
    super.key,
    required this.onTap,
    required this.icon,
    required this.text,
  });

  final Function()? onTap;
  final IconData? icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 140,
        width: 130,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          color: const Color(0xff353434),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: musikatColor2,
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: shortThinStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
