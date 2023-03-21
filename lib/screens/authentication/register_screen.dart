import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/widgets/custom_text_field.dart';
import 'package:musikat_app/widgets/toast_msg.dart';

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

  bool checkMe = false;

  final genderList = ["Prefer not to say", "Male", "Female", "Others"];
  String dropdownValue = 'Prefer not to say';
  bool _passwordVisible = false;
  bool _conPassVisible = false;

  final AuthController _authController = locator<AuthController>();

  String prompts = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _authController,
        builder: (context, Widget? w) {
          if (_authController.working) {
            return const Scaffold(
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
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Image.asset(
                            "assets/images/register_bg.png",
                            width: 250,
                            height: 230,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 25, top: 10),
                          alignment: Alignment.topLeft,
                          child: Text("Create an account for free",
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
                                children: [
                                  emailForm(),
                                  passForm(),
                                  conPassForm(),
                                  usernameForm(),
                                  ageForm(),
                                  genderDropDown(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              child: checkBox(),
                            ),
                            const SizedBox(width: 15.0),
                            Text(
                              'By signing up you accept the MuSikat \n Term of Service and Piracy Policy.',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            prompts,
                            style: GoogleFonts.inter(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        registerButton(),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  Checkbox checkBox() {
    return Checkbox(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        activeColor: Colors.orange,
        value: checkMe,
        onChanged: (bool? value) {
          setState(() => checkMe = value ?? false);
        });
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
      hintText: "Password",
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

  CustomTextField conPassForm() {
    return CustomTextField(
      obscureText: !_conPassVisible,
      controller: _pass2Con,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        } else if (_passCon.text != _pass2Con.text) {
          return 'Passwords do not match!';
        } else if (value.length < 6) {
          return "Password should be atleast 6 characters";
        } else if (value.length > 15) {
          return "Password should not be greater than 15 characters";
        }
        return null;
      },
      hintText: "Confirm Password",
      prefixIcon: const Icon(Icons.lock_outline_sharp),
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _conPassVisible = !_conPassVisible;
          });
        },
        child: Icon(
          _conPassVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
      ),
    );
  }

  CustomTextField usernameForm() {
    return CustomTextField(
      obscureText: false,
      controller: _usernameCon,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else if (value.length < 3) {
          return 'Username must be more than 3 characters';
        } else if (value.length > 25) {
          return 'Username must not exceed to more than 25 characters';
        } else {
          return null;
        }
      },
      hintText: "Username",
      prefixIcon: const Icon(Icons.person),
    );
  }

  CustomTextField ageForm() {
    return CustomTextField(
      obscureText: false,
      controller: _ageCon,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        } else if (int.parse(value) < 18) {
          return 'Age must be 18 and above';
        } else if (int.parse(value) > 100) {
          return 'Age cannot exceed to 100 and above';
        }
        return null;
      },
      keyboardType: TextInputType.number,
      hintText: "Age",
      prefixIcon: const Icon(Icons.numbers),
    );
  }

  Container genderDropDown(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      // padding: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            // color: Theme.of(context).colorScheme.primary,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_drop_down),
        decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.black),
          labelText: "Gender",
          border: InputBorder.none,
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              FaIcon(
                FontAwesomeIcons.marsAndVenus,
                color: Colors.grey,
              ),
              SizedBox(
                width: 15.0,
              ),
            ],
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 2,
          ),
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
        onPressed: () {
          if (isFieldEmpty()) {
            ToastMessage.show(context, 'Please fill in all fields');
          } else if (!checkMe) {
            ToastMessage.show(
                context, 'Please accept the terms and conditions');
          } else {
            if (_formKey.currentState!.validate()) {
              setState(() {
                register();
              });
            } else {
              ToastMessage.show(context, 'Please fill in all fields correctly');
            }
          }
        },
        child: Text(
          'Register',
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Future<void> register() async {
    try {
      await _authController.register(
        email: _emailCon.text.trim(),
        password: _passCon.text.trim(),
        username: _usernameCon.text.trim(),
        age: _ageCon.text.trim(),
        gender: dropdownValue,
      );
      // ignore: use_build_context_synchronously

    } catch (error) {
      setState(() {
        prompts = error.toString();
      });
    }
  }

  bool isFieldEmpty() {
    if (_emailCon.text.isEmpty ||
        _passCon.text.isEmpty ||
        _usernameCon.text.isEmpty ||
        _ageCon.text.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
