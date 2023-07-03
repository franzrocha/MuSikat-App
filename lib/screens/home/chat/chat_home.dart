import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/individual_chat_controller.dart';
import 'package:musikat_app/controllers/navigation/navigation_service.dart';
import 'package:musikat_app/models/chat_message_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/chat/global_chat.dart';
import 'package:musikat_app/screens/home/chat/private_chat.dart';
import 'package:musikat_app/utils/exports.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({Key? key}) : super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final IndividualChatController _chatController = IndividualChatController();
  ChatMessage? message;

  @override
    Widget build(BuildContext context) {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder:
              (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }
            else if(snap.data!.docs.isEmpty){
              return const Center(child: Text('No messages yet', style: TextStyle(color: Colors.white),),);
            }
            else if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }

          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: musikatBackgroundColor,
            appBar: CustomAppBar(
                showLogo: false,
                title: Text(
                  'Messages',
                  style: appBarStyle,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          FadeRoute(
                            page: const GlobalChatScreen(),
                            settings: const RouteSettings(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.transparent,
                        child: Image.asset("assets/images/musikat_global.png"),
                      ),
                    ),
                  ),
                ]),
            body: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    chatList(),
                  ],
                ),
              ),
            ),
          );
        });
  }

StreamBuilder<List<UserModel>> chatList() {
  return StreamBuilder<List<UserModel>>(
    stream: _chatController.fetchChatroomsStream(),
    builder: (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) { // Update the snapshot type
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: LoadingIndicator(),
        );
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      List<UserModel>? data = snapshot.data;
      if (data == null || data.isEmpty) {
        return const Center(
          child: Text(
            'No messages yet',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return Column(
        children: [
          for (UserModel user in data)
            if (user.uid != FirebaseAuth.instance.currentUser!.uid)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  onTap: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PrivateChatScreen(selectedUserUID: user.uid),
                      ),
                    )
                  },
                  leading: AvatarImage(
                    uid: user.uid,
                    radius: 18,
                  ),
                  title: Text(
                    user.username,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
        ],
      );
    },
  );
}
}
