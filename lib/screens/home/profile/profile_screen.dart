import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/profile/account_info.dart';
import 'package:musikat_app/screens/home/profile/liked_songs_screen.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';

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
                TileList(
                  icon: Icons.queue_music,
                  title: 'Playlist',
                  ontap: () {},
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
                  icon: Icons.people,
                  title: 'Following/Follower',
                  ontap: () {},
                ),
                TileList(
                  icon: Icons.info,
                  title: 'About us',
                  ontap: () {},
                ),
                TileList(
                  icon: Icons.logout,
                  title: 'Log-out',
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
    return Text(
      user?.username ?? '',
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 30,
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
            height: 180,
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
        ],
      ),
    );
  }
}
