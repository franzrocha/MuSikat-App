import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/controllers/global_chat_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';

class GlobalChatScreen extends StatefulWidget {
  const GlobalChatScreen({Key? key}) : super(key: key);

  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  final AuthController _auth = locator<AuthController>();
  final GlobalChatController _chatCon = GlobalChatController();

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFN = FocusNode();
  final ScrollController _scrollController = ScrollController();

  UserModel? user;
  @override
  void initState() {
    UserModel.fromUid(uid: _auth.currentUser!.uid).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });
    _chatCon.addListener(scrollToBottom);
    super.initState();
  }

  @override
  void dispose() {
    _chatCon.removeListener(scrollToBottom);
    _messageFN.dispose();
    _messageController.dispose();
    _chatCon.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FittedBox(
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.transparent,
                child: Image.asset("assets/images/musikat_global.png"),
              ),
            ),
            const SizedBox(width: 12),
            Text("Global Chat",
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
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
                                itemCount: _chatCon.chats.length,
                                itemBuilder: (context, index) {
                                  return ChatCard(
                                      scrollController: _scrollController,
                                      index: index,
                                      chat: _chatCon.chats,
                                      isGroup: true,
                                      chatroom: 'globalchat',
                                      recipient: 'globalchat',
                                      
                                      );
                                }),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            Container(
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
                        onFieldSubmitted: (String text) {
                          sendMessage();
                        },
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
                        color: musikatColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                      onPressed: sendMessage,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void sendMessage() {
    _messageFN.unfocus();
    if (_messageController.text.isNotEmpty) {
      _chatCon.sendMessage(message: _messageController.text.trim());
      _messageController.text = '';
    }
  }
}
