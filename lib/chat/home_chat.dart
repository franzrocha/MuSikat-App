// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/chat/chat_list.dart';
import 'package:musikat_app/chat/chat_list_model.dart';
import 'package:musikat_app/chat/chat_screen_private.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

import '../../service_locators.dart';

// ignore: must_be_immutable
class HomeChatScreen extends StatefulWidget {
  static const String route = 'home-screen';
  const HomeChatScreen({Key? key}) : super(key: key);

  @override
  State<HomeChatScreen> createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen> {
  final AuthController _auth = locator<AuthController>();
  final ChatListController _chatListController = ChatListController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFN = FocusNode();
  UserModel? user;

  @override
  void initState() {
    super.initState();
    UserModel.fromUid(uid: _auth.currentUser?.uid ?? "").then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageFN.dispose();
    _messageController.dispose();
    _chatListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder:
            (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
          if (!snap.hasData) {
            return Center(child: LoadingIndicator());
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          return Scaffold(
            backgroundColor: musikatBackgroundColor,
            resizeToAvoidBottomInset: true,
            appBar: CustomAppBar(
              showLogo: false,
              title: Text(
                'Messages',
                style: appBarStyle,
              ),
            ),
            body: body(context),
          );
        });
  }

  SizedBox body(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              messageList(),
            ],
          ),
        ),
      ),
    );
  }

//AsyncSnapshot<dynamic> snapshot
  Widget messageList() {
    return Column(
      children: [
        SizedBox(
          // height: MediaQuery.of(context).size.height / 1.5,
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: _chatListController.chats.isEmpty
                ? bodyNoMessage()
                : bodyWithMessage(),
          ),
        ),

        // ),
      ],
    );
  }

  Widget bodyNoMessage() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          UserModel.fromUid(uid: _auth.currentUser?.uid ?? "").then((value) {
            user = value;
          });
        });
      },
      child: Center(
        child: Column(children: [
          Image.asset("assets/images/no_played.png", width: 300),
          Text(
            "Create your first message on MuSiKat",
            style: shortDefault,
          ),
        ]),
      ),
    );
  }

  Widget bodyWithMessage() {
    return AnimatedBuilder(
        animation: _chatListController,
        builder: (context, snapshot) {
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              reverse: true,
              shrinkWrap: true,
              itemCount: _chatListController.chats.length,
              itemBuilder: (context, index) {
                var chatFriends = _chatListController.extractUID(
                    _chatListController.chats[index].uid,
                    FirebaseAuth.instance.currentUser!.uid);
                if (user == null) {
                  return Container();
                }
                if (_chatListController.chats[index].uid !=
                    FirebaseAuth.instance.currentUser!.uid) {
                  return FutureBuilder<UserModel>(
                      future: UserModel.fromUid(uid: chatFriends),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox(
                            child: Container(),
                          );
                        }

                        return Container(
                          child: messageListTile(context,
                              _chatListController.chats[index], snapshot),
                        );
                      });
                }
                return SizedBox();
              });
        });
  }

  String formatDateReceived(ChatList chatList) {
    if (chatList.ts
            .toDate()
            .compareTo(DateTime.now().subtract(Duration(days: 1))) ==
        -1) {
      if (chatList.ts
              .toDate()
              .compareTo(DateTime.now().subtract(Duration(days: 7))) ==
          -1) {
        return DateFormat("d MMM").format(chatList.ts.toDate());
      } else {
        return DateFormat.EEEE().format(chatList.ts.toDate());
      }
    } else {
      return DateFormat("hh:mm aaa").format(chatList.ts.toDate());
    }
  }

  ListTile messageListTile(BuildContext context, ChatList chatList,
      AsyncSnapshot<UserModel> chatUser) {
    return ListTile(
        onTap: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ChatScreenPrivate(selectedUserUID: chatUser.data!.uid),
                ),
              )
            },
        subtitle: Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            chatList.sentBy == user!.uid
                ? "You: ${chatList.isDeleted ? "message deleted" : chatList.message}"
                : (chatList.isDeleted ? "message deleted" : chatList.message),
            style: TextStyle(
              color: Colors.white,
              fontWeight: chatList.seenBy.contains(user!.uid)
                  ? FontWeight.normal
                  : FontWeight.bold,
            )),
        leading: AvatarImage(
          uid: chatUser.data!.uid,
          radius: 40,
        ),
        title: Text(
          chatUser.data!.username,
          style: TextStyle(
            fontWeight: chatList.seenBy.contains(user!.uid)
                ? FontWeight.normal
                : FontWeight.bold,
            color: Colors.white,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatDateReceived(chatList),
              style: TextStyle(
                fontWeight: chatList.seenBy.contains(user!.uid)
                    ? FontWeight.normal
                    : FontWeight.bold,
                color: Colors.white,
              ),
            ),
            chatList.seenBy.contains(user!.uid)
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.fiber_manual_record_rounded,
                      size: 15,
                      color: Colors.orange,
                    ),
                  ),
          ],
        ));
  }
}
