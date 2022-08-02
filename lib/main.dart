import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/service_locators.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocators();
  runApp(const MyApp());
}

