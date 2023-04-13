import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/widgets/nav_bar.dart';

class NewWelcome extends StatefulWidget {
  const NewWelcome({Key? key}) : super(key: key);
  static const String route = 'new-welcome';
  @override
  State<NewWelcome> createState() => _NewWelcomeState();
}

class _NewWelcomeState extends State<NewWelcome> {
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
      appBar: appBar(context),
      backgroundColor: const Color(0xff262525),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Image.asset("assets/images/welcome.png",
                      width: 300, height: 300),
                ),
                const SizedBox(height: 80),
                Container(
                  padding: const EdgeInsets.only(left: 30, top: 5, bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text("Welcome to \nMusikat, ${user?.firstName ?? ""}!",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 150,
                ),
                proceedButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
    );
  }
}

Container proceedButton(BuildContext context) {
  return Container(
    width: 318,
    height: 63,
    decoration: BoxDecoration(
        color: musikatColor, borderRadius: BorderRadius.circular(60)),
    child: TextButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NavBar(),
        ),
      ),
      child: Text(
        'Proceed',
        style: GoogleFonts.inter(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
