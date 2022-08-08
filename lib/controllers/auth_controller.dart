import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/controllers/navigation/navigation_service.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/service_locators.dart';
import '../screens/home/home_screen.dart';
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

  handleAuthUserChanges(User? event) {
    if (event == null) {
      print('No logged in user');
      nav.popUntilFirst();
      nav.pushReplacementNamed(WelcomeScreen.route);
    }
    if (event != null) {
      print('Logged in user');
      print(event.email);
      // if(currentUser == null){
        
      // }
      nav.pushReplacementNamed(HomeScreen.route);
    }
    error = null;
    working = false;
    currentUser = event;
    notifyListeners();
  }

  Future login(String email, String password) async {
    try {
      working = true;
      notifyListeners();
      UserCredential? result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      print(e.code);
      working = false;
      currentUser = null;
      error = e;
      notifyListeners();
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

  Future register(
      {required String email,
      required String password,
      required String username,
      required String age,
      required String gender}) async {
    try {
      working = true;
      notifyListeners();
      UserCredential createdUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (createdUser.user != null) {
        UserModel userModel = UserModel(createdUser.user!.uid, username, email,
            age, gender, '', Timestamp.now(), Timestamp.now());
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
}
