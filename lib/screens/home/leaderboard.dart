import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import '../../music_player/music_player.dart';
import '../../widgets/display_widgets.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final SongsController _songCon = SongsController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: musikatBackgroundColor,
        appBar: CustomAppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Leaderboard',
                  style: appBarStyle,
                ),
              ),
            ],
          ),
          showLogo: false,
        ),
        body: Column(
          children: [
            TabBar(
                indicator: PillTabIndicator(
                  // Custom indicator
                  indicatorColor: const Color(
                      0xffE28D00), // Color of the pill-shaped indicator
                  indicatorHeight: 50, // Height of the pill-shaped indicator
                ),
                tabs: [
                  const Tab(
                    text: 'Artists',
                  ),
                  const Tab(
                    text: 'Songs',
                  )
                ]),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 50,
                        child: Align(
                          alignment: Alignment
                              .centerLeft, // Aligns the text to the left
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Top artists of the day',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // artiststToLookOut(),
                      Expanded(
                        child: FutureBuilder(
                          future: _songCon.getRankedUsers(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasData) {
                              final List<Map<String, dynamic>> rankedArtists =
                                  snapshot.data!;
                              if (rankedArtists.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No artists found in your library.',
                                    style: shortThinStyle,
                                  ),
                                );
                              }

                              return ListView.separated(
                                itemCount: rankedArtists.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(height: 10),
                                itemBuilder: (BuildContext context, int index) {
                                  final UserModel user =
                                      rankedArtists[index]['user'];
                                  final int percentageScore =
                                      rankedArtists[index]['totalPlayCount'];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArtistsProfileScreen(
                                            selectedUserUID: user.uid,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                user.profileImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '${index + 1}.  ${user.username}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: songTitle,
                                      ),
                                      subtitle: Text(
                                        'Play Counts: ${percentageScore.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              return const Center(
                                child: LoadingIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 50,
                        child: Align(
                          alignment: Alignment
                              .centerLeft, // Aligns the text to the left
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Top songs of the day',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder(
                          future: _songCon.getRanked(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasData) {
                              final List<Map<String, dynamic>> rankedSongs =
                                  snapshot.data!;
                              if (rankedSongs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No songs found in your library.',
                                    style: shortThinStyle,
                                  ),
                                );
                              }

                              return GestureDetector(
                                onTap: () {
                                  print(rankedSongs.length);
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) => MusicPlayerScreen(
                                  //       songs: rankedSongs,
                                  //       initialIndex: index,
                                  //     ),
                                  //   ),
                                  // );
                                  print('test');
                                },
                                child: ListView.separated(
                                  itemCount: rankedSongs.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(height: 10),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final SongModel song =
                                        rankedSongs[index]['song'];
                                    final double percentageScore =
                                        rankedSongs[index]['percentageScore'];
                                    final int playCount =
                                        rankedSongs[index]['playCount'];
                                    final int likedCount =
                                        rankedSongs[index]['likeCount'];

                                    return ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                song.albumCover),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '${index + 1}.  ${song.title}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: songTitle,
                                      ),
                                      subtitle: Text(
                                        'Total Play Count: ${playCount}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              return const Center(
                                child: LoadingIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Expanded(
            //   // child: Container(
            //   //   child: Text('Says Hello', style: TextStyle(fontSize: 50, color: Colors.white),),
            //   // ),
            //   child: FutureBuilder(
            //     future:
            //         _songCon.getRanked(),
            //     builder: (BuildContext context,
            //         AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            //       if (snapshot.hasData) {
            //         final List<Map<String, dynamic>> rankedSongs = snapshot.data!;
            //         if (rankedSongs.isEmpty) {
            //           return Center(
            //             child: Text(
            //               'No songs found in your library.',
            //               style: shortThinStyle,
            //             ),
            //           );
            //         }
            //
            //         return ListView.separated(
            //           itemCount: rankedSongs.length,
            //           separatorBuilder: (BuildContext context, int index) =>
            //               const SizedBox(height: 10),
            //           itemBuilder: (BuildContext context, int index) {
            //             final SongModel song = rankedSongs[index]['song'];
            //             final double percentageScore =
            //                 rankedSongs[index]['percentageScore'];
            //
            //             return ListTile(
            //               leading: Container(
            //                 width: 50,
            //                 height: 50,
            //                 decoration: BoxDecoration(
            //                   image: DecorationImage(
            //                     image:
            //                         CachedNetworkImageProvider(song.albumCover),
            //                     fit: BoxFit.cover,
            //                   ),
            //                 ),
            //               ),
            //               title: Text(
            //                 '${index + 1}.  ${song.title}',
            //                 maxLines: 1,
            //                 overflow: TextOverflow.ellipsis,
            //                 style: songTitle,
            //               ),
            //               subtitle: Text(
            //                 'Percentage Score: ${percentageScore.toStringAsFixed(2)}%',
            //                 style: const TextStyle(
            //                   fontSize: 12,
            //                   color: Colors.grey,
            //                 ),
            //               ),
            //             );
            //           },
            //         );
            //       } else if (snapshot.hasError) {
            //         return Center(
            //           child: Text('Error: ${snapshot.error}'),
            //         );
            //       } else {
            //         return const Center(
            //           child: LoadingIndicator(),
            //         );
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
  // StreamBuilder<List<UserModel>?> artiststToLookOut() {
  //   return StreamBuilder<List<UserModel>?>(
  //     stream: _songCon., // Use the original stream without asStream()
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData || snapshot.data == null) {
  //         return const LoadingCircularContainer();
  //       }
  //       if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       }
  //
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const LoadingCircularContainer();
  //       } else {
  //         List<UserModel> users = snapshot.data!;
  //         Random random = Random(DateTime.now().minute);
  //
  //         users = users
  //             .where(
  //                 (user) => user.uid != FirebaseAuth.instance.currentUser!.uid)
  //             .toList();
  //         users.shuffle(random);
  //
  //         users = users.take(5).toList();
  //
  //         return users.isEmpty
  //             ? const SizedBox.shrink()
  //             : ArtistLeaderBoardDisplay(users: users, caption: 'Artists to look out for');
  //       }
  //     },
  //   );
  // }
}

class PillTabIndicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;

  PillTabIndicator(
      {this.indicatorHeight = 30, this.indicatorColor = Colors.white});

  @override
  _PillTabIndicatorPainter createBoxPainter([VoidCallback? onChanged]) {
    return _PillTabIndicatorPainter(this, onChanged);
  }
}

class _PillTabIndicatorPainter extends BoxPainter {
  final PillTabIndicator decoration;

  _PillTabIndicatorPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = Offset(offset.dx,
            (configuration.size!.height - decoration.indicatorHeight) / 2.0) &
        Size(configuration.size!.width, decoration.indicatorHeight);
    final Paint paint = Paint()..color = decoration.indicatorColor;
    final RRect rRect = RRect.fromRectAndCorners(rect,
        topLeft: const Radius.circular(25),
        topRight: const Radius.circular(25));
    canvas.drawRRect(rRect, paint);
  }
}
