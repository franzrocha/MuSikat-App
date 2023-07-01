import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musikat_app/controllers/firebase_service_user_notif_controller.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/screens/home/browse_screen.dart';
import 'package:musikat_app/screens/home/camera.dart';
import 'package:musikat_app/screens/home/chat/chat_home.dart';
import 'package:musikat_app/screens/home/artist_hub/artists_hub_screen.dart';
import 'package:musikat_app/screens/home/dialog/notification.dart';
import 'package:musikat_app/screens/home/home_screen.dart';
import 'package:musikat_app/screens/home/profile/profile_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/music_player/mini_player.dart';
import 'package:badges/badges.dart' as badges;

class NavBar extends StatefulWidget {
  static const String route = 'navbar';
  const NavBar({
    Key? key,
    required this.musicHandler,
  }) : super(key: key);

  final MusicHandler musicHandler;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int pageIndex = 0;
  Color color = Colors.red;

  static final firebaseService = FirebaseService();
  static final userNotificationController = UserNotificationController();
  static final currentUserId = firebaseService.getCurrentUserId();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(musicHandler: widget.musicHandler),
      const BrowseScreen(),
      Container(),
      ArtistsHubScreen(musicHandler: widget.musicHandler),
      const ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: musikatBackgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          showLogo: true,
          actions: [
            Row(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: userNotificationController
                      .streamUserNotification(currentUserId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      QuerySnapshot? querySnapshot = snapshot.data;
                      int length = querySnapshot!.docs.length;

                      if (snapshot.hasData && length > 0) {
                        return badges.Badge(
                          onTap: () {
                            print('get the value');
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ),
                            );
                          },
                          position: badges.BadgePosition.topEnd(top: 0, end: 3),
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.red,
                          ),
                          badgeContent: Text(
                            length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications, size: 20),
                            onPressed: () {
                              print('get the value');

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      // Handle error case
                      return Text('Error: ${snapshot.error}');
                    }

                    return IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        size: 20,
                        color: Colors.teal,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChatHomeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    FontAwesomeIcons.rocketchat,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
        body: Stack(
          children: [
            pages[pageIndex],
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    key: const Key('miniplayer'),
                    onHorizontalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dx > 0) {
                        widget.musicHandler.player.stop();
                      }
                    },
                    child: StreamBuilder<PlayerState>(
                      stream: widget.musicHandler.player.playerStateStream,
                      builder: (context, snapshot) {
                        if (snapshot.data?.processingState !=
                            ProcessingState.idle) {
                          return Column(
                            children: [
                              MiniPlayer(musicHandler: widget.musicHandler),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
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
                        if (index == 2) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CameraScreen(
                                songs: [],
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            pageIndex = index;
                          });
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
                          icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
                          label: 'Browse',
                        ),
                        BottomNavigationBarItem(
                          icon: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: musikatBackgroundColor,
                            ),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: musikatBackgroundColor,
                              child: FaIcon(
                                FontAwesomeIcons.camera,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          label: '',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(FontAwesomeIcons.music),
                          label: 'Artist\'s Hub',
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
          ],
        ),
      ),
    );
  }
}
