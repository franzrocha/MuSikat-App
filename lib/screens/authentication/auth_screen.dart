import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/controllers/navigation/navigation_service.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/screens/authentication/forgot_password.dart';

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
    } else if (_authController.error != null) {
      String errorMessage =
          _authController.error!.message ?? 'An unknown error occurred';
      ToastMessage.show(context, errorMessage);
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
                child: LoadingIndicator(),
              ),
            );
          } else {
            return Scaffold(
              appBar: CustomAppBar(
                  title: Text(
                    'Login',
                    style: appBarStyle,
                  ),
                  showLogo: false),
              backgroundColor: musikatBackgroundColor,
              resizeToAvoidBottomInset: true,
              body: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Image.asset("assets/images/login_bg.png",
                              width: 210, height: 210),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 30, top: 5),
                          alignment: Alignment.topLeft,
                          child: Text("We are here for OPM.",
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  emailForm(),
                                  passForm(),
                                  forgotPass(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                        loginButton(),
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
        } else if (value.length > 20) {
          return "Password should not be greater than 20 characters";
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
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 12  ,
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

  Container loginButton() {
    return Container(
      width: 318,
      height: 63,
      decoration: BoxDecoration(
          color: musikatColor, borderRadius: BorderRadius.circular(60)),
      child: TextButton(
        onPressed: () async {
          if (isFieldEmpty()) {
            ToastMessage.show(context, 'Please fill in all fields');
          } else if (_formKey.currentState?.validate() ?? false) {
            try {
              await _authController.login(
                  _emailCon.text.trim(), _passCon.text.trim(), 'user');
            } on FirebaseAuthException catch (e) {
              ToastMessage.show(context, e.message ?? '');
            } catch (e) {
              ToastMessage.show(context,
                  'An unknown error occurred. Please try again later.');
            }
          } else {
            ToastMessage.show(context, 'Please fill in all fields correctly');
          }
        },
        child: Text(
          'Log In',
          style: buttonStyle,
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
