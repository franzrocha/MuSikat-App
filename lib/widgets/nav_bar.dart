import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/screens/home/artists_screen.dart';
import 'package:musikat_app/screens/home/categories_screen.dart';
import 'package:musikat_app/screens/home/chat_home_screen.dart';
import 'package:musikat_app/screens/home/fer.dart';
import 'package:musikat_app/screens/home/home_screen.dart';
import 'package:musikat_app/screens/home/profile_screen.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/widgets/search_bar.dart';

class NavBar extends StatefulWidget {
  static const String route = 'navbar';
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int pageIndex = 0;

  Future getImage(bool isCamera) async {}

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final AuthController auth = locator<AuthController>();

    final List<Widget> pages = [
      const HomeScreen(),
      const ArtistsScreen(),
      const FERScreen(),
      const ChatHomeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: musikatBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Image.asset("assets/images/musikat_logo.png",
                width: 45, height: 47),
          ),
          actions: [
            Row(
              children: [
                const Searchbar(),
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
                    size: 20,
                  ),
                ),
              ],
            ),
            //   InkWell(
            //   onTap: () {
            //     ImageService.updateProfileImage();
            //   },
            //   child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
            // ),
            const SizedBox(
              width: 8,
            ),
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
        showSelectedLabels: false, // <-- HERE/ <-
        onTap: (int index) {
          setState(() {
            pageIndex = index;
          });
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
            icon: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.black, shape: BoxShape.circle),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
            label: 'Camera',
          ),
          const BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.comment),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
