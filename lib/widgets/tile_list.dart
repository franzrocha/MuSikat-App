import 'package:musikat_app/utils/exports.dart';

class TileList extends StatelessWidget {
  const TileList(
      {Key? key,
      required this.icon,
      required this.title,
      this.ontap,
      this.subtitle})
      : super(key: key);

  final IconData icon;
  final String title;
  final String? subtitle;
  final void Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        color: const Color(0xff353434),
        child: Center(
          child: ListTile(
            onTap: ontap,
            leading: CircleAvatar(
              backgroundColor: musikatColor2,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle!,
                    style:
                        GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
