import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCon = TextEditingController(),
      _passCon = TextEditingController(),
      _pass2Con = TextEditingController(),
      _usernameCon = TextEditingController(),
      _ageCon = TextEditingController();

  final genderList = ["Prefer not to say", "Male", "Female", "Others"];
  String dropdownValue = 'Prefer not to say';

  final AuthController _authController = locator<AuthController>();

  String prompts = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: const Color(0xff262525),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(top: 20),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Image.asset(
                //         "assets/images/musikat_logo.png",
                //         width: 50,
                //         height: 50,
                //       ),
                //       const SizedBox(width: 14),
                //       Text("MuSikat",
                //           style: GoogleFonts.montserrat(
                //               color: Colors.white,
                //               fontSize: 36,
                //               fontWeight: FontWeight.bold)),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Image.asset(
                    "assets/images/register.png",
                    width: 237,
                    height: 210,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 25, top: 10),
                  alignment: Alignment.topLeft,
                  child: Text("Become a listener or an artist",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
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
                        children: [
                          emailForm(context),
                          passForm(context),
                          conPassForm(context),
                          usernameForm(context),
                          ageForm(context),
                          genderDropDown(context),
                        ],
                      ),
                    ),
                  ),
                ),
                    Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    _authController.error?.message ?? '',
                    style: GoogleFonts.montserrat(color: Colors.red),
                  ),
                ),
                  registerButton(),

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
      title: Text("Register",
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
            return "Please enter your email";
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

  Container passForm(context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xff34B771),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        obscureText: true,
        controller: _passCon,
        validator: (value) {
          if (value!.isEmpty) {
            return "Please enter your password";
          } else if (value.length < 6) {
            return "Password should be atleast 6 characters";
          } else if (value.length > 15) {
            return "Password should not be greater than 15 characters";
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
          fillColor: Colors.white,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          hintText: "Password",
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        ),
      ),
    );
  }

  Container conPassForm(context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xff34B771),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        obscureText: true,
        controller: _pass2Con,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password';
          } else if (_passCon.text != _pass2Con.text) {
            return 'Passwords do not match!';
          }
          return null;
        },
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 17,
        ),
        decoration: const InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          hintText: "Confirm Password",
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        ),
      ),
    );
  }

  Container usernameForm(context) {
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
        // maxLength: 25,
        controller: _emailCon,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter your username';
          } else if (value.length < 3) {
            return 'Username must be more than 3 characters';
          } else if (value.length > 25) {
            return 'Username must not exceed to more than 25 characters';
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
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          hintText: "Username",
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        ),
      ),
    );
  }

  Container ageForm(BuildContext context) {
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
          controller: _ageCon,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            } else if (int.parse(value) < 18) {
              return 'Age must be 18 and above';
            } else if (int.parse(value) > 100) {
              return 'Age cannot exceed to 100 and above';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            hintText: "Age",
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          ),
        ));
  }

  Container genderDropDown(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonFormField(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_drop_down),
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          labelText: "Gender",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        items: genderList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
        },
      ),
    );
  }

  Container registerButton() {
    return Container(
      width: 318,
      height: 63,
      decoration: BoxDecoration(
          color: const Color(0xfffca311),
          borderRadius: BorderRadius.circular(60)),
      child: TextButton(
        onPressed: (){},
        //  onPressed: (_formKey.currentState?.validate() ?? false)
        //     ? () {
        //         _authController.register(
        //           email: _emailCon.text.trim(),
        //           password: _passCon.text.trim(),
        //           username: _usernameCon.text.trim(),
        //           age: _ageCon.text.trim(),
        //          gender: dropdownValue,
                  
        //         );
        //       }
        //     : null,
        child: Text(
          'REGISTER',
          style: GoogleFonts.montserrat(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
