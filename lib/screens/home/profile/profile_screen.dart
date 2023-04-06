import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/profile/account_info.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/widgets/avatar.dart';
import 'package:musikat_app/widgets/tile_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
          child: Center(
            child: Column(
              children: [
                profilePic(),
                userName(),
                const SizedBox(height: 30),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(
                //       '-- \n FOLLOWERS',
                //       textAlign: TextAlign.center,
                //       style: GoogleFonts.inter(
                //         color: Colors.white,
                //         fontSize: 13,
                //       ),
                //     ),
                //     const SizedBox(width: 20),
                //     Text(
                //       '-- \n FOLLOWING',
                //       textAlign: TextAlign.center,
                //       style: GoogleFonts.inter(
                //         color: Colors.white,
                //         fontSize: 13,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 20),
                TileList(
                  icon: Icons.queue_music,
                  text: 'Playlist',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AccountInfoScreen()),
                    );
                  },
                ),
                TileList(
                  icon: FontAwesomeIcons.heart,
                  text: 'Liked Songs',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AccountInfoScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.account_box,
                  text: 'Account Info',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AccountInfoScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.people,
                  text: 'Following/Follower',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AccountInfoScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.info,
                  text: 'About us',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AccountInfoScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.logout,
                  text: 'Log-out',
                  ontap: () async {
                    _auth.logout();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text userName() {
    return Text(user?.username ?? '...',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ));
  }

  Padding profilePic() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Stack(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
        ],
      ),
    );
  }
}
