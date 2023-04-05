import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/screens/home/artist_hub/insights.dart';

import 'package:musikat_app/screens/home/artist_hub/audio_uploader_screen.dart';
import 'package:musikat_app/widgets/avatar.dart';

import 'artist_hub/library_screen.dart';

class ArtistsHubScreen extends StatefulWidget {
  const ArtistsHubScreen({Key? key}) : super(key: key);

  @override
  State<ArtistsHubScreen> createState() => _ArtistsHubScreenState();
}

class _ArtistsHubScreenState extends State<ArtistsHubScreen> {
  final AuthController _auth = locator<AuthController>();

  UserModel? user;

  @override
  void initState() {
    UserModel.fromUid(uid: _auth.currentUser!.uid).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(children: [
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: profilePic(),
                  ),
                ),
              ]),
              Divider(
                  height: 20,
                  indent: 1.0,
                  color: listileColor.withOpacity(0.4)),
              SizedBox(
                height: 150,
                width: 120,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: const Color(0xff353434),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xff62DD69),
                            child: Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Library',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                onTap: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LibraryScreen(),
                    ),
                  )
                },
                trailing: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.white,
                  size: 18,
                ),
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
                trailing: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.white,
                  size: 18,
                ),
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
                trailing: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.white,
                  size: 18,
                ),
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
                trailing: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.white,
                  size: 18,
                ),
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
            ],
          ),
        ),
      ),
    );
  }

  Padding profilePic() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Stack(
        children: [
          SizedBox(
            width: 100,
            height: 120,
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
        ],
      ),
    );
  }
}
