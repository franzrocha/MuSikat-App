import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/following_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/song_charts.dart';

import 'package:musikat_app/utils/exports.dart';

class FollowingListScreen extends StatefulWidget {
  static const String route = 'artists-screen';

  const FollowingListScreen({Key? key}) : super(key: key);

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {
  final FollowController _followCon = FollowController();
  UserModel? user;
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar(context),
        backgroundColor: musikatBackgroundColor,
        body: SafeArea(
          child: TabBarView(
            children: [
              followertab(),
              followingtab(),
            ],
          ),
        ),
      ),
    );
  }

  Column followertab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder<List<String>>(
          future: _followCon
              .getUserFollowers(FirebaseAuth.instance.currentUser!.uid),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final followersCount = snapshot.data!.length;
              return ListTile(
                title: Row(
                  children: [
                    Text('Total Followers: $followersCount',
                        style: shortDefault),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              );
            }
          },
        ),
        // Expanded(
        //   child: FutureBuilder<List<String>>(
        //     future: _followCon.getUserFollowers(
        //         currentUser), // Replace 'currentUser' with the UID of the current user
        //     builder:
        //         (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        //       if (snapshot.hasData) {
        //         final List<String> followers = snapshot.data!;
        //         return ListView.separated(
        //           itemCount: followers.length,
        //           separatorBuilder: (BuildContext context, int index) =>
        //               const SizedBox(height: 10),
        //           itemBuilder: (BuildContext context, int index) {
        //             final String followerId = followers[index];
        //             return FutureBuilder<UserModel>(
        //               future: _followCon.getUserFollowers(followerId),
        //               builder: (BuildContext context,
        //                   AsyncSnapshot<UserModel> snapshot) {
        //                 if (snapshot.hasData) {
        //                   final UserModel follower = snapshot.data!;
        //                   return ListTile(
        //                     leading: Container(
        //                       width: 50,
        //                       height: 50,
        //                       decoration: BoxDecoration(
        //                         shape: BoxShape.circle,
        //                         image: DecorationImage(
        //                           image: NetworkImage(follower
        //                               .profileImage), // Assuming you have the follower's profile picture URL in the UserModel
        //                           fit: BoxFit.cover,
        //                         ),
        //                       ),
        //                     ),
        //                     title: Text(
        //                       follower
        //                           .username, // Assuming you have the follower's name in the UserModel
        //                       maxLines: 1,
        //                       overflow: TextOverflow.ellipsis,
        //                       style: songTitle,
        //                     ),
        //                     // Add any additional information you want to display for each follower

        //                     // Add any onTap functionality for each follower if needed

        //                     // Add any trailing widgets or information you want to display for each follower
        //                   );
        //                 } else if (snapshot.hasError) {
        //                   return Center(
        //                     child: Text('Error: ${snapshot.error}'),
        //                   );
        //                 } else {
        //                   return const Center(
        //                     child: LoadingIndicator(),
        //                   );
        //                 }
        //               },
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
    );
  }

  Column followingtab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder<List<String>>(
          future: _followCon
              .getUserFollowing(FirebaseAuth.instance.currentUser!.uid),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final followingCount = snapshot.data!.length;
              return ListTile(
                title: Row(
                  children: [
                    Text('Total Following: $followingCount',
                        style: shortDefault),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              );
            }
          },
        ),
        // Expanded(
        //   child: FutureBuilder(
        //     future: _songCon.getRankedSongs(),
        //     builder: (BuildContext context,
        //         AsyncSnapshot<List<SongModel>> snapshot) {
        //       if (snapshot.hasData) {
        //         final List<SongModel> songs = snapshot.data!
        //             .where((song) =>
        //                 song.uid == FirebaseAuth.instance.currentUser?.uid)
        //             .toList();

        //         if (songs.isEmpty) {
        //           return Center(
        //             child: Text(
        //               'No songs found in your library.',
        //               style: shortThinStyle,
        //             ),
        //           );
        //         }

        //         return ListView.separated(
        //           itemCount: songs.length > 5 ? 5 : songs.length,
        //           separatorBuilder: (BuildContext context, int index) =>
        //               const SizedBox(height: 10),
        //           itemBuilder: (BuildContext context, int index) {
        //             final SongModel song = songs[index];
        //             return ListTile(
        //               onTap: () {
        //                 Navigator.of(context).push(
        //                   MaterialPageRoute(
        //                     builder: (context) =>
        //                         SongPlayCountChart(songs: songs),
        //                   ),
        //                 );
        //               },
        //               leading: Container(
        //                 width: 50,
        //                 height: 50,
        //                 decoration: BoxDecoration(
        //                   image: DecorationImage(
        //                     image: CachedNetworkImageProvider(song.albumCover),
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
        // Expanded(
        //     child: FutureBuilder<int>(
        //   future:
        //       _songCon.getOverallPlays(FirebaseAuth.instance.currentUser!.uid),
        //   builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return Container();
        //     } else if (snapshot.hasError) {
        //       return Text('Error: ${snapshot.error}');
        //     } else {
        //       return ListTile(
        //         title: Row(
        //           children: [
        //             Text('Overall Streams:', style: sloganStyle),
        //             const SizedBox(
        //               width: 10,
        //             ),
        //             Text('${snapshot.data}', style: sloganStyle),
        //           ],
        //         ),
        //       );
        //     }
        //   },
        // )
        // )
      ],
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Followers/Following',
        style: appBarStyle,
      ),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const FaIcon(FontAwesomeIcons.angleLeft, size: 20)),
      automaticallyImplyLeading: false,
      bottom: TabBar(
        labelStyle: shortDefault,
        labelColor: Colors.white,
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: musikatColor,
        ),
        tabs: const [
          Tab(text: 'Followers'),
          Tab(text: 'Followings'),
        ],
      ),
      backgroundColor: musikatBackgroundColor,
    );
  }
}
