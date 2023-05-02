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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Image.asset(
                              "assets/images/musikat_logo.png",
                              width: 141,
                              height: 140,
                            ),
                          ),
                          Text(
                            "MuSikat",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 38,
                              height: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "LISTEN TO YOUR FAVOURITE \n OPM TRACKS HERE ",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),  
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 318,
                            height: 63,
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
                              child: Text(
                                'Log in',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 318,
                            height: 63,
                            decoration: BoxDecoration(
                              color: musikatColor2,
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign up',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
