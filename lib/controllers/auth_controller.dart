import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/controllers/navigation/navigation_service.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/widgets/nav_bar.dart';
import 'package:musikat_app/service_locators.dart';
import '../screens/authentication/welcome_screen.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription authStream;
  User? currentUser;
  FirebaseAuthException? error;
  bool working = true;
  final NavigationService nav = locator<NavigationService>();

  AuthController() {
    authStream = _auth.authStateChanges().listen(handleAuthUserChanges);
  }

  @override
  dispose() {
    authStream.cancel();
    super.dispose();
  }

  handleAuthUserChanges(User? event) async {
    if (event == null) {
      print('No logged in user');
      nav.popUntilFirst();
      nav.pushReplacementNamed(WelcomeScreen.route);
    }

    if (event != null) {
      print('Logged in user');
      print(event.email);

      String accountType = await getUserAccountType();

      if (accountType.toLowerCase() == 'admin') {
        await logout();
        nav.popUntilFirst();
        nav.pushReplacementNamed(WelcomeScreen.route);
        return;
      }

      nav.pushReplacementNamed(NavBar.route);
    }

    error = null;
    working = false;
    currentUser = event;
    notifyListeners();
  }

  Future<void> login(String email, String password, String accountType) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw Exception('Login failed');
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .get();

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      String accountTypeFirebase = userData['accountType'] as String;

      // Perform account type check
      if (accountTypeFirebase.toLowerCase() != 'user') {
        throw Exception('Invalid account type');
      }

      working = false;
      currentUser = result.user;
      error = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      print(e.code);
      working = false;
      currentUser = null;
      error = e;
      notifyListeners();
      rethrow;
    } catch (e) {
      print(e);
      working = false;
      currentUser = null;
      error = FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      );
      notifyListeners();
      if (error != null) {
        throw error!;
      } else {
        throw Exception('Unknown error occurred');
      }
    }
  }

  Future logout() async {
    working = true;
    notifyListeners();
    await _auth.signOut();
    working = false;
    notifyListeners();
    return;
  }

  Future register({
    required String email,
    required String password,
    required String username,
    required String lastName,
    required String firstName,
    required String age,
    required String gender,
  }) async {
    try {
      working = true;
      notifyListeners();
      UserCredential createdUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (createdUser.user != null) {
        UserModel userModel = UserModel(
          createdUser.user!.uid,
          username,
          lastName,
          firstName,
          email,
          age,
          gender,
          '',
          '',
          Timestamp.now(),
          Timestamp.now(),
          [],
          'User',
          [],
          [],
        );
        return FirebaseFirestore.instance
            .collection('users')
            .doc(userModel.uid)
            .set(userModel.json);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      print(e.code);
      working = false;
      currentUser = null;
      error = e;
      notifyListeners();
    }
  }

  Future resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (error) {
      print(error.message);
      return Future.error(error.message.toString());
    }
  }

  Future<String> getUserAccountType() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('accountType')) {
        return userData['accountType'] as String;
      }
    }

    throw Exception('User account type not found');
  }
}
