import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        title: Text(user?.username ?? '...'),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            profilePic(),
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
