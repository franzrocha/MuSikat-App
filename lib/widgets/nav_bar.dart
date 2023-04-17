import 'package:musikat_app/screens/home/fer.dart';
import 'package:musikat_app/screens/home/search_screen.dart';
import 'package:musikat_app/screens/home/artists_hub_screen.dart';
import 'package:musikat_app/screens/home/categories_screen.dart';
import 'package:musikat_app/screens/home/chat_home_screen.dart';
import 'package:musikat_app/screens/home/home_screen.dart';
import 'package:musikat_app/screens/home/profile/profile_screen.dart';
import 'package:musikat_app/utils/ui_exports.dart';
import 'package:musikat_app/utils/widgets_export.dart';

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
    final List<Widget> pages = [
      const HomeScreen(),
      const ArtistsHubScreen(),
      Container(),
      const ChatHomeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        showLogo: true,
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
      ),
      body: pages[pageIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                  color: musikatBackgroundColor,
                  spreadRadius: 0,
                  blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xffE28D00),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              currentIndex: pageIndex,
              elevation: 4,
              showUnselectedLabels: false,
              showSelectedLabels: true,
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
                      boxShadow: [
                        BoxShadow(
                          color: musikatBackgroundColor,
                          spreadRadius: 0,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundColor: musikatBackgroundColor,
                      child: FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Colors.white,
                        size: 18,
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
      ),
    );
  }
}
