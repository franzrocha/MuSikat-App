// ignore_for_file: must_be_immutable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

class ArtistsProfileScreen extends StatefulWidget {
  ArtistsProfileScreen({Key? key, required this.selectedUserUID})
      : super(key: key);
  String selectedUserUID;

  @override
  State<ArtistsProfileScreen> createState() => _ArtistsProfileScreenState();
}

class _ArtistsProfileScreenState extends State<ArtistsProfileScreen> {
  // final SongsController _songCon = SongsController();
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
              usernameText(),
              fullnameText(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
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
                    width: 190.0,
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
                    width: 190.0,
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
            ])
          ]),
        ),
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

  Align usernameText() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Text(user?.username ?? '',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
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
