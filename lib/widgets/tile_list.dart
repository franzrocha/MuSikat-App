import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';

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
              backgroundColor: musikatColor2,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.inter(fontSize: 17, color: Colors.white),
            ),
            subtitle:  subtitle != null
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
