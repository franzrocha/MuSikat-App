import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/listening_history_screen.dart';
import 'package:musikat_app/screens/home/profile/account_info.dart';
import 'package:musikat_app/screens/home/profile/following_screen.dart';
import 'package:musikat_app/screens/home/profile/liked_songs_screen.dart';
import 'package:musikat_app/screens/home/profile/playlist_screen.dart';
import 'package:musikat_app/screens/home/profile/about_us.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';

import '../../../music_player/music_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _auth = locator<AuthController>();
  MusicHandler musicHandler = locator<MusicHandler>();
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
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                profilePic(),
                fullnameText(),
                const SizedBox(height: 4),
                userName(),
                const SizedBox(height: 15),
                TileList(
                  icon: Icons.queue_music,
                  title: 'Playlist',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const PlaylistScreen()),
                    );
                  },
                ),
                TileList(
                  icon: FontAwesomeIcons.heart,
                  title: 'Liked Songs',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const LikedSongsScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.history,
                  title: 'Listening History',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ListeningHistoryScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.people,
                  title: 'Followers/Following',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const FollowingListScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.account_box,
                  title: 'Account Info',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AccountInfoScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.info,
                  title: 'About us',
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AboutUsScreen()),
                    );
                  },
                ),
                TileList(
                  icon: Icons.logout,
                  title: 'Log-out',
                  ontap: () async {
                    locator<MusicHandler>().setIsPlaying(false);
                    locator<MusicHandler>().player.stop();
                     await Future.delayed(const Duration(seconds: 1)); 
                    _auth.logout();
                  },
                ),
                const SizedBox(height: 130),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text userName() {
    return Text(
      '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
      style: GoogleFonts.inter(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Text fullnameText() {
    return Text(
      user?.username ?? '',
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Padding profilePic() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Stack(
        children: [
          SizedBox(
            width: 180,
            height: 160,
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
        ],
      ),
    );
  }
}
