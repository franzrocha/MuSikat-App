import 'package:musikat_app/controllers/individual_chat_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

class PrivateChatScreen extends StatefulWidget {
  const PrivateChatScreen({
    Key? key,
    required this.selectedUserUID,
    this.chatroom = "",
  }) : super(key: key);
  final String selectedUserUID;
  final String chatroom;

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final IndividualChatController _chatCon = IndividualChatController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFN = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String get chatroom => widget.chatroom;
  UserModel? user;

  @override
  void initState() {
    _chatCon.initChatRoom(_chatCon.generateRoomId(widget.selectedUserUID),
        widget.selectedUserUID);

    _chatCon.addListener(scrollToBottom);
    _messageFN.addListener(scrollToBottom);
    super.initState();
  }

  @override
  void dispose() {
    _messageFN.dispose();
    _messageController.dispose();

    if (_chatCon.messages.isNotEmpty) {
      _chatCon.dispose();
    }
    super.dispose();
  }

  scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 250));
    print('scrolling to bottom');
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          curve: Curves.easeIn, duration: const Duration(milliseconds: 250));
    }
  }

  // scrollBottom() async {
  //   await Future.delayed(const Duration(milliseconds: 250));
  //   print('scrolling to bottom');
  //   if (_scrollController.hasClients) {
  //     _scrollController.animateTo(
  //         _scrollController.position.viewportDimension +
  //             _scrollController.position.maxScrollExtent,
  //         curve: Curves.easeIn,
  //         duration: const Duration(milliseconds: 250));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
        future: UserModel.fromUid(uid: widget.selectedUserUID),
        builder: (BuildContext context, AsyncSnapshot<UserModel> selectedUser) {
             if (selectedUser.hasError) {
                return Center(child: Text('Error: ${selectedUser.error}'));
              }

              if (selectedUser  .connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              } 
          if (!selectedUser.hasData) {
            return const  Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
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
            resizeToAvoidBottomInset: true,
            appBar: CustomAppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AvatarImage(uid: widget.selectedUserUID, radius: 20),
                  const SizedBox(width: 12),
                  Text(selectedUser.data!.username,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              showLogo: false,
            ),
            backgroundColor: musikatBackgroundColor,
            body: StreamBuilder(
              stream: _chatCon.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == "null") {
                    return const LoadingIndicator();
                  } else if (snapshot.data == "success") {
                    return body(
                      context,
                      messages,
                      send,
                    );
                  } else if (snapshot.data == 'empty') {
                    return body(
                      context,
                      firstMessage,
                      sendFirst,
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                }
                return const LoadingIndicator();
              },
            ),
          );
        });
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

  Expanded messages() {
    return Expanded(
      child: AnimatedBuilder(
        animation: _chatCon,
        builder: (context, Widget? w) {
          return SingleChildScrollView(
            physics: const ScrollPhysics(),
            controller: _scrollController,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _chatCon.messages.length,
                      itemBuilder: (context, index) {
                        return ChatCard(
                          scrollController: _scrollController,
                          index: index,
                          chat: _chatCon.messages,
                          chatroom: _chatCon.chatroom ?? '',
                          recipient: widget.selectedUserUID,
                        );
                      }),
                ],
              ),
            ),
          );
        },
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

  Expanded firstMessage() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/musikat_logo.png", width: 100),
          const SizedBox(height: 20,),
          Text('Start your legendary conversation', 
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          ),
          const SizedBox(
            height: 60,
          )
        ],
      ),
    );
  }

  send() {
    _messageFN.unfocus();
    if (_messageController.text.isNotEmpty) {
      _chatCon.sendMessage(message: _messageController.text.trim());
      _messageController.text = '';
    }
  }

  sendFirst() async {
    _messageFN.unfocus();

    if (_messageController.text.isNotEmpty) {
      var chatroom = _chatCon.sendFirstMessage(
        message: _messageController.text.trim(),
        recipient: widget.selectedUserUID,
      );
      _messageController.text = '';
      try {
        setState(() {
          _chatCon.initChatRoom(chatroom, widget.selectedUserUID);
        });
      } catch (e) {
        print(e);
      }
    }
  }
}