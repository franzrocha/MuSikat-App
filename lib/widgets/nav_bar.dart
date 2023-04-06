import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musikat_app/screens/home/fer.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/screens/home/artists_hub_screen.dart';
import 'package:musikat_app/screens/home/categories_screen.dart';
import 'package:musikat_app/screens/home/chat_home_screen.dart';
import 'package:musikat_app/screens/home/home_screen.dart';
import 'package:musikat_app/screens/home/profile/profile_screen.dart';
import 'package:musikat_app/service_locators.dart';

import '../screens/home/search_screen.dart';

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
    // ignore: unused_local_variable
    final AuthController auth = locator<AuthController>();

    final List<Widget> pages = [
      const HomeScreen(),
      const ArtistsHubScreen(),
      Container(),
      const ChatHomeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appbar(context),
      body: pages[pageIndex],
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xffE28D00),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            currentIndex: pageIndex,
            elevation: 3,
            showUnselectedLabels: false,
            showSelectedLabels: false,
            onTap: (int index) {
              if (index != 2) {
                setState(() {
                  pageIndex = index;
                });
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.music),
                label: 'Artists Hub',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: musikatBackgroundColor,
                  ),
                  child: const CircleAvatar(
                    backgroundColor: musikatBackgroundColor,
                    child: FaIcon(
                      FontAwesomeIcons.magnifyingGlassChart,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 35,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      backgroundColor: musikatBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Image.asset(
          "assets/images/musikat_logo.png",
          width: 30,
          height: 35,
        ),
      ),
      actions: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.category,
                size: 25,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FERScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.camera_alt,
                size: 25,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }
}
