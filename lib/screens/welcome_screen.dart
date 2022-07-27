import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: const AssetImage("assets/images/background.jpg"),
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), BlendMode.darken),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("assets/images/musikat_logo.png",
                    width: 141, height: 141),
                Text("MuSikat",
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold)),
                    Text("LISTEN TO YOUR FAVOURITE \n OPM TRACKS HERE ",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500)),
                        
              ],
            ),
          ),
        ),
      ),
    );
  }
}
