import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/widgets/avatar.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.chat))
        ],
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                profilePic(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? '...',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "---- followers",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      )),
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
