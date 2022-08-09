import 'package:flutter/material.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({Key? key}) : super(key: key);

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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