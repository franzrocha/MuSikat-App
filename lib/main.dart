import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/screens/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuSikat',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
      theme: ThemeData().copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: Colors.green,
            ),
      ),
    );
  }
}
