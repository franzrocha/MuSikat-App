import 'package:flutter/material.dart';
import 'package:musikat_app/constants.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({Key? key}) : super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: Column(
          children: const [
            Text('CHAT HOME'),
          ],
        ),
      ),
    );
  }
}
