import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/services/image_service.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/widgets/header_image.dart';

import '../../../widgets/avatar.dart';

class EditHubScreen extends StatefulWidget {
  const EditHubScreen({super.key});

  @override
  State<EditHubScreen> createState() => _EditHubScreenState();
}

class _EditHubScreenState extends State<EditHubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: appbar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  ImageService.updateHeaderImage();
                },
                child: SizedBox(
                  height: 230,
                  child: Stack(
                    children: [
                      HeaderImage(uid: FirebaseAuth.instance.currentUser!.uid),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: profilePic(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding profilePic() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              ImageService.updateProfileImage();
            },
            child: SizedBox(
              width: 100,
              height: 120,
              child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text("Edit Hub",
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      backgroundColor: const Color(0xff262525),
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const FaIcon(
          FontAwesomeIcons.angleLeft,
          size: 20,
        ),
      ),
    );
  }
}
