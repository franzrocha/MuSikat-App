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
    // ignore: unnecessary_null_comparison
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
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Image.asset("assets/images/musikat_logo.png",
                            width: 141, height: 141),
                      ),
                      Text("MuSikat",
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold)),
                      Text("LISTEN TO YOUR FAVOURITE \n OPM TRACKS HERE ",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      Container(
                        width: 318,
                        height: 63,
                        decoration: BoxDecoration(
                            color: musikatColor,
                            borderRadius: BorderRadius.circular(60)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const AuthScreen()),
                            );
                          },
                          child: Text(
                            'Log in',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Container(
                        width: 318,
                        height: 63,
                        decoration: BoxDecoration(
                            color: musikatColor2,
                            borderRadius: BorderRadius.circular(60)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Sign up',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Text("or connect with",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                      const Divider(
                          color: Color(0xff707579),
                          thickness: 0.4,
                          indent: 50,
                          endIndent: 50,
                          height: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 57,
                            height: 56,
                            decoration: BoxDecoration(
                                color: const Color(0xff1877F2),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextButton(
                              onPressed: () {},
                              child: const FaIcon(
                                FontAwesomeIcons.facebook,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 31),
                          Container(
                            width: 57,
                            height: 56,
                            decoration: BoxDecoration(
                                color: const Color(0xffffffff),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextButton(
                              onPressed: () {},
                              child: const FaIcon(FontAwesomeIcons.google,
                                  color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
