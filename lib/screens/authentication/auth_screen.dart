import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/widgets/nav_bar.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/widgets/custom_text_field.dart';
import '../../controllers/navigation/navigation_service.dart';
import 'package:musikat_app/screens/authentication/forgot_password.dart';

import '../../widgets/toast_msg.dart';

class AuthScreen extends StatefulWidget {
  static const String route = 'auth-screen';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCon = TextEditingController(),
      _passCon = TextEditingController();
  final AuthController _authController = locator<AuthController>();

  bool _passwordVisible = false;

  String prompts = '';

  @override
  void initState() {
    _authController.addListener(handleLogin);
    super.initState();
  }

  @override
  void dispose() {
    _emailCon.dispose();
    _passCon.dispose();
    _authController.removeListener(handleLogin);
    super.dispose();
  }

  handleLogin() {
    if (_authController.currentUser != null) {
      locator<NavigationService>().pushReplacementNamed(NavBar.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _authController,
        builder: (context, Widget? w) {
          if (_authController.working) {
            return const Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: musikatBackgroundColor,
              body: Center(
                child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      backgroundColor: Color(0xff34b771),
                      valueColor: AlwaysStoppedAnimation(
                        Color(0xfffca311),
                      ),
                      strokeWidth: 10,
                    )),
              ),
            );
          } else {
            return Scaffold(
              appBar: appBar(context),
              backgroundColor: const Color(0xff262525),
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Image.asset("assets/images/login_bg.png",
                              width: 230, height: 230),
                        ),
                        // const SizedBox(height: 10),
                        // Text("MuSikat",
                        //     style: GoogleFonts.montserrat(
                        //         color: Colors.white,
                        //         fontSize: 36,
                        //         fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 30, top: 10, bottom: 5),
                          alignment: Alignment.topLeft,
                          child: Text("We are here for OPM.",
                              textAlign: TextAlign.right,
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Form(
                              key: _formKey,
                              onChanged: () {
                                _formKey.currentState?.validate();
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  emailForm(),
                                  const SizedBox(height: 10),
                                  SizedBox(height: 90, child: passForm()),
                                  forgotPass(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                        loginButton(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  CustomTextField emailForm() {
    return CustomTextField(
      obscureText: false,
      controller: _emailCon,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      hintText: 'Email',
      prefixIcon: const Icon(Icons.email),
    );
  }

  CustomTextField passForm() {
    return CustomTextField(
      obscureText: !_passwordVisible,
      controller: _passCon,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else if (value.length < 6) {
          return "Password should be atleast 6 characters";
        } else if (value.length > 15) {
          return "Password should not be greater than 15 characters";
        } else {
          return null;
        }
      },
      hintText: 'Password',
      errorMaxLines: 2,
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
        child: Icon(
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
      ),
    );
  }

  Container forgotPass(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding authErrorMsg() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        _authController.error?.message ?? '',
        style: GoogleFonts.montserrat(color: Colors.red),
      ),
    );
  }

  Container loginButton() {
    return Container(
      width: 318,
      height: 63,
      decoration: BoxDecoration(
          color: buttonColor, borderRadius: BorderRadius.circular(60)),
      child: TextButton(
        onPressed: () {
          if (isFieldEmpty()) {
            ToastMessage.show(context, 'Please fill in all fields');
          } else if (_formKey.currentState?.validate() ?? false) {
            _authController.login(_emailCon.text.trim(), _passCon.text.trim());
          } else {
            ToastMessage.show(context, 'Please fill in all fields correctly');
          }
        },
        child: Text(
          'Log In',
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text("Log in",
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
    );
  }

  bool isFieldEmpty() {
    if (_emailCon.text.isEmpty || _passCon.text.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
