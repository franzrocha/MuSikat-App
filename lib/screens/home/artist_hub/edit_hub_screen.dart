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
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    HeaderImage(
                        uid: FirebaseAuth.instance.currentUser!.uid),
                    InkWell(
                      onTap: () => ImageService.updateHeaderImage(context),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white.withOpacity(0.8),
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                    profilePic(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Align profilePic() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 30, bottom: 10),
        child: InkWell(
          onTap: () {
            ImageService.updateProfileImage(context);
          },
          child: Stack(
            children: [
              SizedBox(
                width: 100,
                height: 120,
                child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
              ),
              Positioned(
                left: 35,
                top: 45,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white.withOpacity(0.8),
                  size: 35,
                ),
              ),
            ],
          ),
        ),
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
