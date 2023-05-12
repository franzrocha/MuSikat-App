import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import '../models/chat_message_model.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({
    Key? key,
    required this.index,
    required this.scrollController,
    required this.chat,

  }) : super(key: key);
  final ScrollController scrollController;
  final int index;
  final List<ChatMessage> chat;
  

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  var isVisible = false;
  List<ChatMessage> get chat => widget.chat;
  int get index => widget.index;
  ScrollController get scrollController => widget.scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          Visibility(
              visible: index == 0,
              child: const SizedBox(
                height: 10,
              )),
          Visibility(
            visible: isVisible,
            child: Container(
              padding: const EdgeInsets.only(bottom: 5, top: 15),
              alignment: Alignment.center,
              width: double.infinity,
              child: Text(
                DateFormat("MMM d, y hh:mm aaa")
                    .format(chat[index].ts.toDate()),
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 8,
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Visibility(
                visible: chat[index].isEdited && !chat[index].isDeleted
                    ? chat[index].sentBy ==
                        FirebaseAuth.instance.currentUser?.uid
                    : false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    '(edited)',
                    style:
                        GoogleFonts.inter(fontSize: 7, color: Colors.white70),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                  onLongPress: () {
                    chat[index].isDeleted
                        ? null
                        : chat[index].sentBy ==
                                FirebaseAuth.instance.currentUser?.uid
                            ? bottomModal(context)
                            : null;
                  },
                  child: Column(
                    crossAxisAlignment: chat[index].sentBy ==
                            FirebaseAuth.instance.currentUser?.uid
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if ((chat[index].sentBy !=
                              FirebaseAuth.instance.currentUser?.uid) &&
                          (index == 0 ||
                              chat[index - 1].sentBy != chat[index].sentBy))
                        FutureBuilder<UserModel>(
                            future: UserModel.fromUid(uid: chat[index].sentBy),
                            builder: (context, AsyncSnapshot<UserModel> snap) {
                              return Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, top: 5, bottom: 5),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArtistsProfileScreen(
                                            selectedUserUID: chat[index].sentBy,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          child: (chat[index].sentBy !=
                                                      FirebaseAuth.instance
                                                          .currentUser?.uid) &&
                                                  (index == 0 ||
                                                      chat[index - 1].sentBy !=
                                                          chat[index].sentBy)
                                              ? AvatarImage(
                                                  uid: chat[index].sentBy,
                                                  radius: 10,
                                                )
                                              : Container(),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '${snap.data?.username}',
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ));
                            }),
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: chat[index].isDeleted
                                    ? Colors.white
                                    : musikatColor4),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            color: chat[index].isDeleted
                                ? Colors.transparent
                                : chat[index].sentBy ==
                                        FirebaseAuth.instance.currentUser?.uid
                                    ? yourChat
                                    : otherChat,
                          ),
                          child: Text(
                            chat[index].message,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: chat[index].isDeleted
                                  ? Colors.white70
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: chat[index].isEdited && !chat[index].isDeleted
                    ? chat[index].sentBy ==
                            FirebaseAuth.instance.currentUser?.uid
                        ? false
                        : true
                    : false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    '(edited)',
                    style:
                        GoogleFonts.inter(fontSize: 7, color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: isVisible,
            child: Container(
              padding: const EdgeInsets.only(bottom: 2, top: 2),
              alignment: Alignment.center,
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 5.0, right: 10, left: 10),
                child: Row(
                  mainAxisAlignment: chat[index].sentBy ==
                          FirebaseAuth.instance.currentUser?.uid
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      chat[index].seenBy.length >= 5
                          ? "Seen by 4+ "
                          : "Seen by ",
                      style:
                          GoogleFonts.inter(fontSize: 8, color: Colors.white70),
                    ),
                    if (chat[index].seenBy.length < 5)
                      for (String uid in chat[index].seenBy)
                          
                        FutureBuilder(
                            future: UserModel.fromUid(uid: uid),
                            builder: (context, AsyncSnapshot snap) {
                              if (snap.hasData) {
                                final username = snap.data?.username ?? '';
                                final isLast = chat[index].seenBy.last == uid;
                                final separator = isLast ? '' : ', ';
                                return Text(
                                  '$username$separator',
                                  style: GoogleFonts.inter(
                                      fontSize: 8, color: Colors.white70),
                                );
                              }
                              return const SizedBox();
                            }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // );
  }

  Future<dynamic> bottomModal(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: musikatColor4,
      context: context,
      builder: (context) => SingleChildScrollView(
          child: ChatBottomField(
        chat: chat[index],
      )),
    );
  }
}
