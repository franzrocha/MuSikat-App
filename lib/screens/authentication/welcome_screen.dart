import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:musikat_app/screens/authentication/register_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String route = 'welcome-screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  ImageProvider? backgroundImage;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final byteData = await rootBundle.load('assets/images/background.jpg');
    setState(() {
      backgroundImage = MemoryImage(byteData.buffer.asUint8List());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (backgroundImage == null) {
      return const SizedBox();
    } else {
      return Scaffold(
        backgroundColor: musikatBackgroundColor,
        body: SafeArea(
          child: Container(
            constraints: const BoxConstraints.expand(),
            child: Stack(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: backgroundImage!,
                    fadeInDuration: const Duration(milliseconds: 500),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    logo(),
                    buttons(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Expanded logo() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30), // Padding(musikatLogo()
            musikatLogo(),
            const Text(
              "MuSikat",
              style: TextStyle(
                fontFamily: 'Gotham',
                color: Colors.white,
                fontSize: 40,
                height: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  FadeAnimatedText(
                    "Your music, your way.",
                    duration: const Duration(milliseconds: 5000),
                    textStyle: const TextStyle(
                      fontFamily: 'Gotham',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  FadeAnimatedText(
                    "The hub for OPM.",
                    duration: const Duration(milliseconds: 5000),
                    textAlign: TextAlign.center,
                    textStyle: const TextStyle(
                      fontFamily: 'Gotham',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  FadeAnimatedText(
                    "We are here for OPM.",
                    duration: const Duration(milliseconds: 5000),
                    textAlign: TextAlign.center,
                    textStyle: const TextStyle(
                      fontFamily: 'Gotham',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded buttons(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 60,
              decoration: BoxDecoration(
                color: musikatColor,
                borderRadius: BorderRadius.circular(60),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Log in",
                  style: TextStyle(
                    fontFamily: 'Gotham',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 270,
              height: 60,
              decoration: BoxDecoration(
                color: musikatColor2,
                borderRadius: BorderRadius.circular(60),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Sign up",
                  style: TextStyle(
                    fontFamily: 'Gotham',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding musikatLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Image.asset(
        "assets/images/musikat_logo.png",
        width: 141,
        height: 140,
      ),
    );
  }
}
