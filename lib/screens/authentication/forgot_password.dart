// ignore_for_file: use_build_context_synchronously

import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';

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
      appBar: CustomAppBar(
        title: Text(
          'Forgot Password',
          style: appBarStyle,
        ),
        showLogo: false,
      ),
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
                          width: 200,
                          height: 220,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child:
                              Text('Forgot your password?', style: sloganStyle),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                            'Enter your e-mail address you have used to register with us and we will send you a reset link.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            )),
                      ),
                      const SizedBox(height: 20),
                      emailForm(),
                      const Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 30),
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
          child: Text('Submit', style: buttonStyle)),
    );
  }

  bool isFieldEmpty() {
    return !(isEmailEmpty);
  }

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
