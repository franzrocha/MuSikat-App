import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/widgets/avatar.dart';
import 'package:musikat_app/widgets/tile_list.dart';

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
                TileList(
                  icon: Icons.person,
                  title: 'Name',
                  subtitle: '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                ),
                TileList(
                  icon: Icons.person_pin,
                  title: 'Username',
                  subtitle: user?.username ?? '',
                ),
                TileList(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: user?.email ?? '',
                ),
                TileList(
                  icon: Icons.numbers,
                  title: 'Age',
                  subtitle: user?.age ?? '',
                ),
                TileList(
                  icon: FontAwesomeIcons.marsAndVenus,
                  title: 'Gender',
                  subtitle: user?.gender ?? '',
                ),
                TileList(
                  icon: FontAwesomeIcons.calendar,
                  title: 'Account created',
                  subtitle: user?.created == null
                      ? "..."
                      : DateFormat("MMMM dd, yyyy").format(
                          user!.created.toDate(),
                        ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
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
          ),
        ),
      ],
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
