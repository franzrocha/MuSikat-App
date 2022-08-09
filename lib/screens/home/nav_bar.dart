import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/screens/home/artists_screen.dart';
import 'package:musikat_app/screens/home/chat_home_screen.dart';
import 'package:musikat_app/screens/home/home_screen.dart';
import 'package:musikat_app/screens/home/profile_screen.dart';
import 'package:musikat_app/service_locators.dart';

class NavBar extends StatefulWidget {
  static const String route = 'navbar';
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    int pageIndex = 0;
      final AuthController auth = locator<AuthController>();

    final List<Widget> pages = [
      const HomeScreen(),
      const ArtistsScreen(),
      const ChatHomeScreen(),
      const ProfileScreen(),
    ];

    // void _onItemTapped(int index) {
    //   setState(() {
    //    pageIndex = index;
    //   });
    // }

    return Scaffold(
      appBar: AppBar(
         backgroundColor: const Color(0xffE28D00),
         automaticallyImplyLeading: false,
         toolbarHeight: 65,
         actions:[
           IconButton(
              onPressed: () async {
                auth.logout();
              },
              icon: const Icon(Icons.logout)),
         ]
      ),
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
