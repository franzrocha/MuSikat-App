import 'package:flutter/services.dart';
import 'package:musikat_app/controllers/navigation/navigation_service.dart';
import 'package:musikat_app/screens/authentication/registration_second_screen.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCon = TextEditingController(),
      _ageCon = TextEditingController(),
      _firstNameCon = TextEditingController(),
      _lastNameCon = TextEditingController();

  bool checkMe = false;

  final genderList = ["Prefer not to say", "Male", "Female", "Others"];
  String dropdownValue = 'Prefer not to say';

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
                child: LoadingIndicator(),
              ),
            );
          } else {
            return Scaffold(
              appBar: CustomAppBar(
                title: Text(
                  'Register',
                  style: appBarStyle
                ),
                showLogo: false,
              ),
              backgroundColor: musikatBackgroundColor,
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Image.asset(
                            "assets/images/register_bg.png",
                            width: 250,
                            height: 220,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 25, top: 10),
                          alignment: Alignment.topLeft,
                          child: Text("Create an account for free",
                              textAlign: TextAlign.right,
                              style: sloganStyle),
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
                                  firstNameForm(),
                                  lastNameForm(),
                                  usernameForm(),
                                  ageForm(),
                                  genderDropDown(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: nextButton(context)),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  Container nextButton(BuildContext context) {
    return Container(
      width: 190,
      height: 50,
      decoration: BoxDecoration(
          color: musikatColor, borderRadius: BorderRadius.circular(60)),
      child: TextButton(
        onPressed: () {
          if (isFieldEmpty()) {
            ToastMessage.show(context, 'Please fill in all fields');
          } else {
            Navigator.of(context).push(
              FadeRoute(
                page: RegistrationSecondScreen(
                  lastName: _lastNameCon.text.trim(),
                  firstName: _firstNameCon.text.trim(),
                  age: _ageCon.text.trim(),
                  gender: dropdownValue,
                  username: _usernameCon.text.trim(),
                ),
                settings: const RouteSettings(),
              ),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: buttonStyle,
            ),
            const SizedBox(
              width: 10,
            ),
            const FaIcon(
              FontAwesomeIcons.angleRight,
              size: 18,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  CustomTextField firstNameForm() {
    return CustomTextField(
      hintText: 'First Name',
      controller: _firstNameCon,
      obscureText: false,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      prefixIcon: const Icon(Icons.label_important),
    );
  }

  CustomTextField lastNameForm() {
    return CustomTextField(
      hintText: 'Last Name',
      controller: _lastNameCon,
      obscureText: false,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      prefixIcon: const Icon(Icons.label),
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
      prefixIcon: const Icon(Icons.person_pin_circle),
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_drop_down),
        decoration: const InputDecoration(
          labelStyle: TextStyle(color: Colors.black),
          labelText: "Gender",
          border: InputBorder.none,
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children:  [
              FaIcon(
                FontAwesomeIcons.marsAndVenus,
                color: Colors.grey,
              ),
              SizedBox(
                width: 15.0,
              ),
            ],
          ),
          prefixIconConstraints:  BoxConstraints(
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

  bool isFieldEmpty() {
    if (_lastNameCon.text.isEmpty ||
        _firstNameCon.text.isEmpty ||
        _usernameCon.text.isEmpty ||
        _ageCon.text.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
