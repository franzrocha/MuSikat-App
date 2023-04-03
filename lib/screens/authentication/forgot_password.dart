import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/widgets/custom_text_field.dart';
import 'package:musikat_app/widgets/toast_msg.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCon = TextEditingController();
  final AuthController auth = locator<AuthController>();
  final _formKey = GlobalKey<FormState>();
  String prompts = '';
  bool isEmailEmpty = false;

  @override
  void dispose() {
    _emailCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          width: 240,
                          height: 240,
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
                      emailForm(),
                      const Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 30),
                        // child: Text(
                        //   prompts,
                        //   style: GoogleFonts.inter(
                        //     color: Colors.red,
                        //     fontSize: 12,
                        //   ),
                        // ),
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
          'Submit',
          style: GoogleFonts.inter(
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

// ignore_for_file: use_build_context_synchronously
Future<void> resetPass() async {
  try {
    if (_emailCon.text.trim().isEmpty) {
      ToastMessage.show(context, 'Please enter an email address');
    } else {
      bool result = await auth.resetPassword(email: _emailCon.text.trim());
      if (result) {
        FocusScope.of(context).unfocus();
        ToastMessage.show(context, 'Password reset link sent');
        _emailCon.clear();
      }
    }
  } catch (error) {
    setState(() {
      ToastMessage.show(context, error.toString());
    }); 
  }
}

}
