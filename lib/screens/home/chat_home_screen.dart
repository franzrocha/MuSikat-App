import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/screens/home/global_chat.dart';

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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: ListTile(
                onTap: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GlobalChatScreen(),
                    ),
                  )
                },
                leading: FittedBox(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("assets/images/musikat_global.png"),
                  ),
                ),
                title: Text(
                  "Global Chat",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
