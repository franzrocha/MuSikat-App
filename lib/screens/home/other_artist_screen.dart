import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/widgets/avatar.dart';
import 'package:musikat_app/widgets/header_image.dart';

// ignore: must_be_immutable
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
      appBar: appbar(),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 230,
              child: Stack(children: [
                HeaderImage(uid: selectedUserUID),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: profilePic(),
                  ),
                ),
                Positioned(
                  bottom: 17,
                  left: 30,
                  child: Text(user?.username ?? '',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  top: 215,
                  left: 30,
                  child: Text(user?.username ?? '',
                      style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          
          ],
        ),
      )),
    );
  }

  AppBar appbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.chat))],
    );
  }

  Padding profilePic() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Stack(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: AvatarImage(uid: selectedUserUID),
          ),
        ],
      ),
    );
  }
}
