// ignore_for_file: must_be_immutable
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
  String get selectedUserUID => widget.selectedUserUID;
  UserModel? user;

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
        child: Column(
          children: [
            SizedBox(
              height: 230,
              child: Stack(children: [
                HeaderImage(uid: selectedUserUID),
                profilePic(),
              ]),
            ),
            fullnameText(),
            usernameText(),
          ],
        ),
      )),
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
}
