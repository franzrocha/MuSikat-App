import 'package:flutter/material.dart';

import 'package:musikat_app/constants.dart';
import 'package:musikat_app/models/user_model.dart';

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
      body: AppBar(
        title: Text(user?.username ?? '...'),
        backgroundColor: musikatBackgroundColor,
      ),
    );

    return const Scaffold();
  }
}
  