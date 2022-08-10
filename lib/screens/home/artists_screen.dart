import 'package:flutter/material.dart';

class ArtistsScreen extends StatefulWidget {
  static const String route = 'artists-screen';
  const ArtistsScreen({Key? key}) : super(key: key);

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xff262525),
      body: Center(
        child: Column(
          children:const [
            Text('ARTISTS SCREEN'),
          ],
        ),
      ),
    );
  }
}