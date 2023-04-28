import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/screens/home/music_player.dart';

class ArtistsProfileScreen extends StatefulWidget {
  ArtistsProfileScreen({Key? key, required this.selectedUserUID})
      : super(key: key);
  String selectedUserUID;

  @override
  State<ArtistsProfileScreen> createState() => _ArtistsProfileScreenState();
}

class FollowButton extends StatefulWidget {
  const FollowButton(
      {required this.isFollowing, required this.onFollowChanged});

  final bool? isFollowing;
  final Function(bool isFollowing) onFollowChanged;

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool? _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isFollowing = !_isFollowing!;
          widget.onFollowChanged(_isFollowing!);
        });
      },
      child: Text(
        _isFollowing == true ? 'Unfollow' : 'Follow',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
          primary:
              _isFollowing == true ? Color(0xff62DD69) : Color(0xfffca311)),
    );
  }
}

class _ArtistsProfileScreenState extends State<ArtistsProfileScreen> {
  final SongsController _songCon = SongsController();
  String get selectedUserUID => widget.selectedUserUID;
  UserModel? user;
  int followers = 0;
  bool isFollowing = false;

  @override
  void initState() {
    UserModel.fromUid(uid: selectedUserUID).then((value) {
      if (mounted) {
        setState(() {
          user = value!;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          showLogo: false,
        ),
        backgroundColor: musikatBackgroundColor,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                HeaderImage(uid: FirebaseAuth.instance.currentUser!.uid),
                profilePic(),
              ],
            ),
          ),
          Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fullnameText(),
                  ],
                ),
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        'Followers: ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.0,
                        ),
                      ),
                      Text(
                        followers.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'Following: ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.0,
                        ),
                      ),
                      Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            usernameText(),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 30.0),
                SizedBox(
                  width: 190.0, // Increase the width to 150.0
                  child: FollowButton(
                    isFollowing: isFollowing,
                    onFollowChanged: (bool isFollowing) {
                      setState(() {
                        if (isFollowing) {
                          followers++;
                        } else {
                          followers--;
                        }
                        this.isFollowing = isFollowing;
                      });
                    },
                  ),
                ),
                SizedBox(
                    width:
                        15.0), // Increase the width to 20.0 to create more space between the buttons
                SizedBox(
                  width: 190.0, // Increase the width to 150.0
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle message button press
                    },
                    child: Text('Message'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
                height: 20, indent: 1.0, color: listileColor.withOpacity(0.4)),
            SizedBox(
              height: 170,
              width: double.infinity,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                const SizedBox(height: 10),
                StreamBuilder<List<SongModel>>(
                    stream: _songCon
                        .getLatestSong(FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container();
                      }

                      if (snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Text(
                            "No songs found in your library",
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        final latestSong = snapshot.data!.first;

                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, top: 10, bottom: 15),
                                child: Text('Latest Release',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 30),
                                  child: InkWell(
                                    onLongPress: () {
                                      showModalBottomSheet(
                                          backgroundColor: musikatColor4,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SingleChildScrollView(
                                              child: SongBottomField(
                                                songId: latestSong.songId,
                                              ),
                                            );
                                          });
                                    },
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MusicPlayerScreen(
                                                    songs: [latestSong],
                                                    // username: latestSong.artist,
                                                  )));
                                    },
                                    child: Container(
                                      height: 105,
                                      width: 110,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              latestSong.albumCover),
                                          fit: BoxFit.cover,
                                        ),
                                        color: Colors.grey.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    }),
              ]),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, top: 15, bottom: 10),
                child: Text("Artist's Songs",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ])
        ]))));
  }

  Align profilePic() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 30, bottom: 10),
        child: Stack(
          children: [
            SizedBox(
              width: 100,
              height: 120,
              child: AvatarImage(uid: selectedUserUID),
            ),
          ],
        ),
      ),
    );
  }

  Align usernameText() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(user?.username ?? '',
            style: GoogleFonts.inter(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Align fullnameText() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(
          '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
