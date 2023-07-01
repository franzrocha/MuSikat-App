// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import '../models/chat_message_model.dart';

class ChatCard extends StatefulWidget {
  ChatCard({
    Key? key,
    this.isGroup = false,
    this.hideOptions,
    required this.index,
    required this.scrollController,
    required this.chat,
    required this.chatroom,
    required this.recipient,
  }) : super(key: key);
  final ScrollController scrollController;
  final int index;
  final List<ChatMessage> chat;
  final bool isGroup;
  final String chatroom;
  final String recipient;
  bool? hideOptions;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  var isVisible = false;
  double space = 0;
  List<ChatMessage> get chat => widget.chat;
  ScrollController get scrollController => widget.scrollController;
  int get index => widget.index;
  String get chatroom => widget.chatroom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          messageDate(context),
          messageBubble(context),
          messageSeen(context),
        ],
      ),
    );
    // );
  }

  Row messageBubble(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
      children: [
        editedLeft(context),
        messageBody(context),
        editedRight(context),
      ],
    );
  }

  Container messageBody(BuildContext context) {
    return Container(
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
              : chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
                  ? bottomModal(context)
                  : null;
        },
        child: Column(
          crossAxisAlignment:
              chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            if ((chat[index].sentBy !=
                    FirebaseAuth.instance.currentUser?.uid) &&
                (index == 0 || chat[index - 1].sentBy != chat[index].sentBy))
              FutureBuilder<UserModel>(
                  future: UserModel.fromUid(uid: chat[index].sentBy),
                  builder: (context, AsyncSnapshot<UserModel> snap) {
                    if (!snap.hasData) {
                      return Container();
                    }
                    return Padding(
                      padding: widget.isGroup
                          ? const EdgeInsets.only(top: 20.0, bottom: 5)
                          : const EdgeInsets.only(top: 10.0, bottom: 5),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArtistsProfileScreen(
                                    selectedUserUID: chat[index].sentBy,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              child: (chat[index].sentBy !=
                                          FirebaseAuth
                                              .instance.currentUser?.uid) &&
                                      (index == 0 ||
                                          chat[index - 1].sentBy !=
                                              chat[index].sentBy)
                                  ? AvatarImage(
                                      uid: chat[index].sentBy,
                                      radius: 10,
                                    )
                                  : Container(),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 5, top: 5, bottom: 3),
                            child: Text(
                              '${snap.data?.username}',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            if (chat[index].isDeleted)
              Container(
                padding: widget.isGroup
                    ? EdgeInsets.only(left: space)
                    : const EdgeInsets.only(left: 0),
                child: deletedMessage(context),
              )
            else
              Container(
                padding: widget.isGroup
                    ? EdgeInsets.only(left: space)
                    : const EdgeInsets.only(left: 0),
                child: stringMessage(context),
              ),
          ],
        ),
      ),
    );
  }

  Container stringMessage(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.3),
      padding: const EdgeInsets.all(12),
      decoration: backgroundColor(context),
      child: Text(
          overflow: TextOverflow.visible,
          chat[index].message,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: chat[index].isDeleted
                ? Colors.transparent
                : chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
                    ? Colors.white70
                    : Colors.white,
          )),
    );
  }

  Container deletedMessage(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.3),
      padding: const EdgeInsets.all(12),
      decoration: backgroundColor(context),
      child: Text(
        overflow: TextOverflow.visible,
        "message deleted",
        style: GoogleFonts.inter(
            fontSize: 12, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }

  BoxDecoration backgroundColor(BuildContext context) {
    return BoxDecoration(
        border: Border.all(
            color: chat[index].isDeleted ? Colors.white : musikatColor4),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: chat[index].isDeleted
            ? Colors.transparent
            : chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
                ? yourChat
                : otherChat);
  }

  Visibility messageSeen(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: Row(
            mainAxisAlignment:
                chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Text(
                chat[index].seenBy.length >= 5 ? "Seen by 4+ " : "Seen by ",
                style: GoogleFonts.inter(fontSize: 8, color: Colors.white70),
              ),
              if (chat[index].seenBy.length < 5)
                for (int i = 0; i < chat[index].seenBy.length; i++)
                  FutureBuilder(
                    future: UserModel.fromUid(uid: chat[index].seenBy[i]),
                    builder: (context, AsyncSnapshot snap) {
                      if (snap.hasData) {
                        final username = snap.data?.username ?? '';
                        final isLast = i == chat[index].seenBy.length - 1;
                        final separator = isLast ? '' : ', ';
                        return Text(
                          '$username$separator',
                          style: GoogleFonts.inter(
                              fontSize: 8, color: Colors.white70),
                        );
                      }
                      return const SizedBox();
                    },
                  )
            ],
          ),
        ),
      ),
    );
  }

  Visibility editedRight(BuildContext context) {
    return Visibility(
      visible: chat[index].isEdited
          ? chat[index].isDeleted
              ? false
              : chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
                  ? false
                  : true
          : false,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          '(edited)',
          style: GoogleFonts.inter(fontSize: 7, color: Colors.white70),
        ),
      ),
    );
  }

  Visibility editedLeft(BuildContext context) {
    return Visibility(
      visible: chat[index].isEdited
          ? chat[index].isDeleted
              ? false
              : chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
          : false,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          '(edited)',
          style: GoogleFonts.inter(fontSize: 7, color: Colors.white70),
        ),
      ),
    );
  }

  Visibility messageDate(BuildContext context) {
    return Visibility(
        visible: isVisible,
        child: Container(
          // color: Colors.red,
          padding: const EdgeInsets.only(bottom: 5, top: 15),
          alignment: Alignment.center,
          width: double.infinity,
          child: Text(
            DateFormat("MMM d, y hh:mm aaa").format(chat[index].ts.toDate()),
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ));
  }

  Future<dynamic>? bottomModal(BuildContext context) {
    if (chatroom == 'globalchat') {
      return null;
    }

    return showModalBottomSheet(
      backgroundColor: musikatColor4,
      context: context,
      builder: (context) =>
          SingleChildScrollView(child: ChatBottomField(chat: chat[index], chatroom: chatroom,)),
    );
  }
}
