// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:musikat_app/chat/card_chat.dart';
import 'package:musikat_app/chat/chat_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

class ChatScreenPrivate extends StatefulWidget {
  final String chatroom;
  final String selectedUserUID;
  const ChatScreenPrivate(
      {Key? key, required this.selectedUserUID, this.chatroom = ""});

  @override
  State<ChatScreenPrivate> createState() => _ChatScreenPrivateState();
}

class _ChatScreenPrivateState extends State<ChatScreenPrivate> {
  // final AuthController _auth = locator<AuthController>();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFN = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final IndividualChatController _chatController = IndividualChatController();
  String get selectedUserUID => widget.selectedUserUID;

  String get chatroom => widget.chatroom;
  UserModel? user;

  @override
  void initState() {
    _chatController.initChatRoom(
        _chatController.generateRoomId(selectedUserUID), selectedUserUID);

    _chatController.addListener(scrollToBottom);
    _messageFN.addListener(scrollToBottom);
    super.initState();
  }

  scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          curve: Curves.easeIn, duration: const Duration(milliseconds: 250));
    }
  }

  @override
  void dispose() {
    _messageFN.dispose();
    _messageController.dispose();

    if (_chatController.messages.isNotEmpty) {
      _chatController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
        future: UserModel.fromUid(uid: selectedUserUID),
        builder: (BuildContext context, AsyncSnapshot<UserModel> selectedUser) {
          if (!selectedUser.hasData) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: LoadingIndicator(),
                  ),
                ],
              ),
            );
          }
          return Scaffold(
            backgroundColor: musikatBackgroundColor,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: musikatBackgroundColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const FaIcon(
                  FontAwesomeIcons.angleLeft,
                  size: 20,
                ),
              ),
              title: Row(
                children: [
                  AvatarImage(uid: selectedUser.data!.uid, radius: 15),
                  SizedBox(
                    width: 15,
                  ),
                  Flexible(
                    child: Text(selectedUser.data!.username,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: shortDefault),
                  ),
                ],
              ),
            ),
            body: StreamBuilder(
              stream: _chatController.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == "null") {
                    return loadingScreen("1");
                  } else if (snapshot.data == "success") {
                    return body(context, message, send);
                  } else if (snapshot.data == 'empty') {
                    return body(context, firstMessage, firstSend);
                  }
                } else if (snapshot.hasError) {
                  return loadingScreen(snapshot.error.toString());
                }
                return loadingScreen("3");
              },
            ),
          );
        });
  }

  Center loadingScreen(String num) {
    return Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          LoadingIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Loading", style: shortDefault),
          ),
        ]));
  }

  SizedBox body(BuildContext context, Function message, Function send) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          message(),
          textFormField(context, send),
        ],
      ),
    );
  }

  Container textFormField(BuildContext context, Function send) {
    return Container(
      height: MediaQuery.of(context).size.height / 15,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: 285,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12)),
              child: TextFormField(
                focusNode: _messageFN,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 12,
                ),
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message....',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                      left: 12, bottom: 12, top: 10, right: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: musikatColor, borderRadius: BorderRadius.circular(15)),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
              onPressed: () => send(),
            ),
          )
        ],
      ),
    );
  }

  Expanded message() {
    return Expanded(
      child: AnimatedBuilder(
          animation: _chatController,
          builder: (context, Widget? w) {
            return SingleChildScrollView(
              physics: ScrollPhysics(),
              controller: _scrollController,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _chatController.messages.length,
                        itemBuilder: (context, index) {
                          return CardChat(
                            scrollController: _scrollController,
                            index: index,
                            chat: _chatController.messages,
                            chatroom: _chatController.chatroom ?? '',
                            recipient: selectedUserUID,
                          );
                        }),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Expanded firstMessage() {
    return Expanded(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Image.asset("assets/images/register_bg2.png", width: 300,),
              SizedBox(height: 30),
              Text(
                'Start a conversation with this user.',
                style: shortDefault,
              ),
              SizedBox(height: 60)
            ],
          ),
        ),
      ),
    );
  }

  send() {
    _messageFN.unfocus();
    if (_messageController.text.isNotEmpty) {
      _chatController.sendMessage(
          message: _messageController.text.trim(), recipient: selectedUserUID);
      _messageController.text = '';
    }
  }

  firstSend() async {
    _messageFN.unfocus();

    if (_messageController.text.isNotEmpty) {
      var chatroom = _chatController.sendFirstMessage(
        message: _messageController.text.trim(),
        recipient: selectedUserUID,
      );
      _messageController.text = '';
      try {
        setState(() {
          _chatController.initChatRoom(chatroom, selectedUserUID);
        });
      } catch (e) {
        print(e);
      }
    }
  }
}
