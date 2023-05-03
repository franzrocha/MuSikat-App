// ignore_for_file: must_be_immutable
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

class ArtistsProfileScreen extends StatefulWidget {
  ArtistsProfileScreen({Key? key, required this.selectedUserUID})
      : super(key: key);
  String selectedUserUID;

  @override
  State<ArtistsProfileScreen> createState() => _ArtistsProfileScreenState();
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
          user = value;
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat),
          ),
        ],
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<UserModel>(
            stream: UserModel.fromUidStream(uid: selectedUserUID),
            builder: (context, AsyncSnapshot<UserModel?> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: LoadingIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          HeaderImage(uid: selectedUserUID),
                          profilePic(),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        usernameText(snapshot),
                        fullnameText(snapshot),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10),
                          child: Row(
                            children: [
                              const Text(
                                'Followers: ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13.0,
                                ),
                              ),
                              Text(
                                followers.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                ),
                              ),
                              const SizedBox(width: 30.0),
                              const Text(
                                'Following: ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13.0,
                                ),
                              ),
                              const Text(
                                '0',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const SizedBox(width: 30.0),
                            SizedBox(
                              width: 130.0,
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
                            const SizedBox(width: 15.0),
                            SizedBox(
                              width: 130.0,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text('Support'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(
                            height: 20,
                            indent: 1.0,
                            color: listileColor.withOpacity(0.4)),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: StreamBuilder<List<SongModel>>(
                          stream: _songCon.getLatestSong(selectedUserUID),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Container();
                            }

                            if (snapshot.data!.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Text(
                                    "The user hasn't uploaded any songs yet.",
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                             fontSize: 18,
                                        ),
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            } else {
                              final latestSong = snapshot.data!.first;

                              return Column(children: [
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
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MusicPlayerScreen(
                                                songs: [latestSong],
                                              ),
                                            ),
                                          );
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          latestSong.title.length > 20
                                              ? '${latestSong.title.substring(0, 20)}...'
                                              : latestSong.title,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(latestSong.genre,
                                            style: GoogleFonts.inter(
                                              color: Colors.grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ]);
                            }
                          }),
                    ),
                  ]),
                );
              }
            }),
      ),
    );
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

  Align usernameText(snapshot) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(snapshot.data!.username,
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Align fullnameText(snapshot) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(
          '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
          style: GoogleFonts.inter(
              color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FollowButton extends StatefulWidget {
  const FollowButton(
      {super.key, required this.isFollowing, required this.onFollowChanged});

  final bool? isFollowing;
  final Function(bool isFollowing) onFollowChanged;

  @override
  State<StatefulWidget> createState() => _FollowButtonState();
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
      style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing == true
              ? const Color(0xff62DD69)
              : const Color(0xfffca311)),
      child: Text(
        _isFollowing == true ? 'Unfollow' : 'Follow',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
