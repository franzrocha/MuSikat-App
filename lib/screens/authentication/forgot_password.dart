import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
}
