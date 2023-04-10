import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/services/image_service.dart';
import 'package:musikat_app/widgets/avatar.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({Key? key}) : super(key: key);

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final AuthController _auth = locator<AuthController>();
  UserModel? user;

  @override
  void initState() {
    UserModel.fromUid(uid: _auth.currentUser!.uid).then((value) {
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
      appBar: appbar(context),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                profilePic(context),
                const SizedBox(height: 20),
                const Divider(height: 20, indent: 1.0, color: listileColor),
                usernameTile(),
                const Divider(height: 20, indent: 1.0, color: listileColor),
                emailTile(),
                const Divider(height: 20, indent: 1.0, color: listileColor),
                ageTile(),
                const Divider(height: 20, indent: 1.0, color: listileColor),
                genderTile(),
                const Divider(height: 20, indent: 1.0, color: listileColor),
                accountCreatedTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListTile emailTile() {
    return ListTile(
      leading: const Icon(Icons.email, color: Colors.white, size: 25),
      title: Text(
        'Email',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        user?.email ?? '...',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  ListTile usernameTile() {
    return ListTile(
      leading: const Icon(
        Icons.person,
        color: Colors.white,
        size: 30,
      ),
      title: Text(
        'Username',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        user?.username ?? '...',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  ListTile ageTile() {
    return ListTile(
      leading: const Icon(
        Icons.numbers,
        color: Colors.white,
        size: 30,
      ),
      title: Text(
        'Age',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            user?.age ?? '...',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'years old',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  ListTile genderTile() {
    return ListTile(
      leading: const FaIcon(
        FontAwesomeIcons.marsAndVenus,
        color: Colors.white,
        size: 30,
      ),
      title: Text(
        'Gender',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        user?.gender ?? '...',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text(
        "Account info",
        textAlign: TextAlign.right,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
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
      actions: [
        IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.edit,
          size: 20,
        ),),
      ],
    );
  }

  ListTile accountCreatedTile() {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.calendar,
          color: Colors.white, size: 25),
      title: Text(
        'Account created',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        user?.created == null
            ? "..."
            : DateFormat("MMMM dd, yyyy").format(
                user!.created.toDate(),
              ),
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Padding profilePic(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Stack(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
        ],
      ),
    );
  }
}
