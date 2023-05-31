import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/following_controller.dart';
import 'package:musikat_app/models/user_model.dart';

import 'package:musikat_app/utils/exports.dart';

import '../other_artist_screen.dart';

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
              final followers = snapshot.data!;
              final followersCount = followers.length;
              return Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Text('Total Followers: $followersCount',
                            style: shortDefault),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Followers:', style: shortDefault),
                  const SizedBox(height: 5),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: followersCount,
                    itemBuilder: (BuildContext context, int index) {
                      final follower = followers[index];
                      return FutureBuilder<UserModel>(
                        future: UserModel.fromUid(uid: follower),
                        builder: (BuildContext context,
                            AsyncSnapshot<UserModel> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(); // Placeholder until user data is fetched
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final user = snapshot.data!;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ArtistsProfileScreen(
                                              selectedUserUID: user.uid,
                                            )));
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profileImage),
                                ),
                                title: Text(
                                  user.username,
                                  style: const TextStyle(
                                    color: Colors
                                        .white, // Set the text color to white
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
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
              final following = snapshot.data!;
              final followingCount = following.length;
              return Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Text('Total Followings: $followingCount',
                            style: shortDefault),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Following:', style: shortDefault),
                  const SizedBox(height: 5),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: followingCount,
                    itemBuilder: (BuildContext context, int index) {
                      final followings = following[index];
                      return FutureBuilder<UserModel>(
                        future: UserModel.fromUid(uid: followings),
                        builder: (BuildContext context,
                            AsyncSnapshot<UserModel> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(); // Placeholder until user data is fetched
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final user = snapshot.data!;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ArtistsProfileScreen(
                                              selectedUserUID: user.uid,
                                            )));
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profileImage),
                                ),
                                title: Text(
                                  user.username,
                                  style: const TextStyle(
                                    color: Colors
                                        .white, // Set the text color to white
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
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
