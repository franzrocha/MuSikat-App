import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/screens/home/artist_hub/insights.dart';

import 'package:musikat_app/screens/home/artist_hub/audio_uploader_screen.dart';

import 'artist_hub/library_screen.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({Key? key}) : super(key: key);

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(children: [
            ListTile(
               onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LibraryScreen(),
                  ),
                )
              },
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Library',
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
                'Albums',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AudioUploaderScreen(),
                  ),
                )
              },
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Upload a file',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InsightsScreen(),
                  ),
                )
              },
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Insights',
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
                'Patreon for Artists',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
          ]),
        ),
      ),
    );
  }
}
