import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/screens/home/artists_screen.dart';
import 'package:musikat_app/screens/home/chat_home_screen.dart';
import 'package:musikat_app/screens/home/home_screen.dart';
import 'package:musikat_app/screens/home/profile_screen.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/services/image_service.dart';
import 'package:musikat_app/widgets/avatar.dart';

class NavBar extends StatefulWidget {
  static const String route = 'navbar';
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
 
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
   
    final AuthController auth = locator<AuthController>();

    final List<Widget> pages = [
      const HomeScreen(),
      const ArtistsScreen(),
      const ChatHomeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xffE28D00),
          automaticallyImplyLeading: false,
          toolbarHeight: 65,
          actions: [
            InkWell(
            onTap: () {
              ImageService.updateProfileImage();
            },
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
          const SizedBox(
            width: 8,
          ),
            IconButton(
                onPressed: () async {
                  auth.logout();
                },
                icon: const Icon(Icons.logout)),
          ]),
      body: pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xffE28D00),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: pageIndex,
        elevation: 3,
        showUnselectedLabels: false,
        onTap: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.music),
            label: 'Artists Hub',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.comment),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
