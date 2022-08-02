import 'package:flutter/material.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/service_locators.dart';

class HomeScreen extends StatefulWidget {
  static const String route = 'home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final AuthController _auth = locator<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const Text('Hello bestie'),
          IconButton(
              onPressed: () async {
                _auth.logout();
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
    ));
  }
}
