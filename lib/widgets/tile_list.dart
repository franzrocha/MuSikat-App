import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TileList extends StatelessWidget {
  const TileList(
      {Key? key,
      required this.icon,
      required this.text, this.ontap})
      : super(key: key);

  final IconData icon;
  final String text;
  final void Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 380,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        color: const Color(0xff353434),
        child: Center(
          child: ListTile(
            onTap: ontap,
            leading: CircleAvatar(
              backgroundColor: const Color(0xff62DD69),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            title: Text(
              text,
              style: GoogleFonts.inter(fontSize: 17, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
