import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/screens/home/camera.dart';
import 'package:musikat_app/screens/home/chat/chat_home.dart';
import 'package:musikat_app/screens/home/recently_played_screen.dart';
import 'package:musikat_app/screens/home/search_screen.dart';
import 'package:musikat_app/screens/home/artist_hub/artists_hub_screen.dart';
import 'package:musikat_app/screens/home/categories/categories_screen.dart';
import 'package:musikat_app/screens/home/home_screen.dart';
import 'package:musikat_app/screens/home/profile/profile_screen.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/music_player/mini_player.dart';

class NavBar extends StatefulWidget {
  static const String route = 'navbar';
  const NavBar({Key? key, required this.musicHandler, }) : super(key: key);

  final MusicHandler musicHandler;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int pageIndex = 0;
  final MusicHandler _musicHandler = locator<MusicHandler>();
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        musicHandler: widget.musicHandler,
      ),
      ArtistsHubScreen(
        musicHandler: widget.musicHandler
        
        ),
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
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(
                        songs: [],
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.camera_alt,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RecentlyPlayedScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.history,
                  size: 20,
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
          height: 160,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                // if (widget.musicHandler.currentSongs.isNotEmpty)
              MiniPlayer(musicHandler: widget.musicHandler),
              ClipRRect(
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
                  elevation: 2,
                  showUnselectedLabels: false,
                  showSelectedLabels: true,
                  selectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
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
                      icon: FaIcon(
                        FontAwesomeIcons.house,
                        size: 20,
                      ),
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
                        size: 30,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
