import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';

class RegistrationSecondScreen extends StatefulWidget {
  const RegistrationSecondScreen(
      {super.key,
      required this.username,
      required this.age,
      required this.gender,
      required this.lastName,
      required this.firstName});

  final String username;
  final String age;
  final String gender;
  final String lastName;
  final String firstName;

  @override
  State<RegistrationSecondScreen> createState() =>
      _RegistrationSecondScreenState();
}

class _RegistrationSecondScreenState extends State<RegistrationSecondScreen> {
  final AuthController _authController = locator<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCon = TextEditingController(),
      _passCon = TextEditingController(),
      _pass2Con = TextEditingController();

  bool _passwordVisible = false;
  bool _conPassVisible = false;
  bool checkMe = false;
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
                child: LoadingIndicator(),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: musikatBackgroundColor,
              appBar: CustomAppBar(
                title: Text(
                  'Register',
                  style: appBarStyle,
                ),
                showLogo: false,
              ),
              body: SafeArea(
                  child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Image.asset(
                          "assets/images/register_bg2.png",
                          width: 250,
                          height: 210,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 25, top: 10),
                        alignment: Alignment.topLeft,
                        child: Text("Be an artist. Be a fan. ",
                            textAlign: TextAlign.right, style: sloganStyle),
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
                            ],
                          ),
                        )),
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
                          const Text(
                            'By signing up you accept the MuSikat \n Term of Service and Piracy Policy.',
                            style:TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      registerButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              )),
            );
          }
        });
  }

  Container registerButton() {
    return Container(
      width: 318,
      height: 63,
      decoration: BoxDecoration(
          color: musikatColor, borderRadius: BorderRadius.circular(60)),
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
          style: buttonStyle),
      ),
    );
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

  bool isFieldEmpty() {
    if (_emailCon.text.isEmpty || _passCon.text.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> register() async {
    try {
      await _authController.register(
        email: _emailCon.text.trim(),
        password: _passCon.text.trim(),
        lastName: widget.lastName,
        firstName: widget.firstName,
        username: widget.username,
        age: widget.age,
        gender: widget.gender,
      );
      // ignore: use_build_context_synchronously
    } catch (error) {
      setState(() {
        prompts = error.toString();
      });
    }
  }
}
