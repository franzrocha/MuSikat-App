import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
=======
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';
>>>>>>> main

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
<<<<<<< HEAD
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
=======
  final _emailCon = TextEditingController();
  final AuthController auth = locator<AuthController>();
  final _formKey = GlobalKey<FormState>();
  String prompts = '';
  bool isEmailEmpty = false;

  @override
  void dispose() {
    _emailCon.dispose();
>>>>>>> main
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: musikatBackgroundColor,
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Image.asset("assets/images/Forgot_password.png",
              width: 200, height: 200),
        ),
        SizedBox(height: 30),
        Text('Forgot your password?',
            textAlign: TextAlign.left,
            style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Text(
              'Enter your e-mail address you have used to register with us and we will send you a reset link.',
              textAlign: TextAlign.left,
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.normal)),
        ),
        SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.email),
              hintText: 'Email',
              fillColor: Colors.grey[200],
              filled: true,
            ),
          ),
        ),
        SizedBox(height: 50),
        MaterialButton(
          onPressed: () {},
          child: Text(
            'Reset Password',
            style: GoogleFonts.montserrat(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          color: const Color(0xfffca311),
        ),
      ]),
    );
  }
=======
      appBar: appBar(context),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              onChanged: () {
                _formKey.currentState?.validate();
                if (mounted) {
                  setState(() {});
                }
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15),
                        child: Image.asset(
                          "assets/images/Forgot_password.png",
                          width: 254,
                          height: 254,
                        ),
                      ),
                      Text('Forgot your password?',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                            'Enter your e-mail address you have used to register with us and we will send you a reset link.',
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                            )),
                      ),
                      const SizedBox(height: 20),
                      emailForm(context),
                       Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 30),
                          child: Text(
                            prompts,
                            style: GoogleFonts.inter(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 45),
                        child: resetButton(context),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container emailForm(context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xff34B771),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        controller: _emailCon,
        validator: (value) {
          if (value!.isEmpty) {
            return null;
          } else {
            return null;
          }
        },
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 17,
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.email),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          hintText: "Email",
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        ),
      ),
    );
  }

  Container resetButton(context) {
    return Container(
      width: 318,
      height: 63,
      decoration: BoxDecoration(
          color: const Color(0xfffca311),
          borderRadius: BorderRadius.circular(60)),
      child: TextButton(
        onPressed: () {
          resetPass();
        },
        child: Text(
          'SUBMIT',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
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
      title: Text("Forgot Password",
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
    return !(isEmailEmpty);
  }

  Future<void> resetPass() async {
    try {
      bool result = await auth.resetPassword(email: _emailCon.text.trim());
      if (result) {
        // ignore: use_build_context_synchronously
        FocusScope.of(context).unfocus();
        final snackBar = SnackBar(
          backgroundColor: buttonColor2,
          content: const Text(
            'Check your email for password reset link',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (error) {
      setState(() {
        prompts = error.toString();
      });
    }
  }
>>>>>>> main
}
