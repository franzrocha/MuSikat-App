import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:musikat_app/utils/constants.dart';

class InsightsScreen extends StatefulWidget {
  static const String route = 'artists-screen';
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}


class _InsightsScreenState extends State<InsightsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(children: [
            ListTile(
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Song Plays',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Likes',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              title: Text(
                'Top Tracks',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.normal),
              ),
            ),
            const SizedBox(height: 150),
            ListTile(
              title: Text(
                'Top Location',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.normal),
              ),
            ),

              
          ]),
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text("Insights",
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      backgroundColor: const Color(0xff262525),
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
