// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:musikat_app/chat/message_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:musikat_app/widgets/avatar.dart';

// ignore: must_be_immutable
class CardChat extends StatefulWidget {
  const CardChat(
      {Key? key,
      this.isGroup = false,
      required this.index,
      required this.scrollController,
      required this.chatroom,
      required this.chat,
      required this.recipient})
      : super(key: key);

  final ScrollController scrollController;
  final int index;
  final bool isGroup;
  final List<Message> chat;
  final String chatroom;
  final String recipient;
  @override
  State<CardChat> createState() => _CardChatState();
}

class _CardChatState extends State<CardChat> {
  var isVisible = false;
  double space = 0;
  List<Message> get chat => widget.chat;
  ScrollController get scrollController => widget.scrollController;
  int get index => widget.index;
  String get chatroom => widget.chatroom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Spacer(index: index),
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
                  ? null
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
                          ? EdgeInsets.only(top: 20.0, bottom: 5)
                          : EdgeInsets.only(top: 10.0, bottom: 5),
                      child: Row(
                        children: [
                          Container(
                              padding:
                                  EdgeInsets.only(left: 5, top: 5, bottom: 3),
                              child: Text(
                                '${snap.data?.username}',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                    );
                  }),
            if (chat[index].isDeleted)
              Container(
                padding: widget.isGroup
                    ? EdgeInsets.only(left: space)
                    : EdgeInsets.only(left: 0),
                child: deletedMessage(context),
              )
            else
              Container(
                padding: widget.isGroup
                    ? EdgeInsets.only(left: space)
                    : EdgeInsets.only(left: 0),
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
        style: TextStyle(
            fontSize: 12,
            color: chat[index].isDeleted
                ? Colors.white
                : chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
                    ? Colors.white
                    : Colors.white),
      ),
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
        style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.titleMedium?.color),
      ),
    );
  }

  BoxDecoration backgroundColor(BuildContext context) {
    return BoxDecoration(
      border: Border.all(
          color: chat[index].isDeleted
              ? Colors.white
              : Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: chat[index].isDeleted
          ? Colors.transparent
          : chat[index].sentBy == FirebaseAuth.instance.currentUser?.uid
              ? yourChat
              : otherChat
    );
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
                chat[index].seenBy.length > 1 ? "Seen by " : "Sent",
                style: TextStyle(color: Colors.grey, fontSize: 8),
              ),
              for (String uid in chat[index].seenBy)
                FutureBuilder(
                    future: UserModel.fromUid(uid: uid),
                    builder: (context, AsyncSnapshot snap) {
                      if (snap.hasData &&
                          chat[index].seenBy.length > 1 &&
                          snap.data?.uid !=
                              FirebaseAuth.instance.currentUser!.uid) {
                        return Container(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            width: 22,
                            child: AvatarImage(uid: snap.data?.uid));
                      }
                      return Text('');
                    }),
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
        padding: EdgeInsets.all(5),
        child: Text(
          '(edited)',
          style: Theme.of(context).textTheme.bodySmall,
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
        padding: EdgeInsets.all(5),
        child: Text(
          '(edited)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Visibility messageDate(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        padding: EdgeInsets.only(bottom: 5, top: 15),
        alignment: Alignment.center,
        width: double.infinity,
        child: Text(
          DateFormat("MMM d, y hh:mm aaa").format(chat[index].ts.toDate()),
          style: TextStyle(color: Colors.grey, fontSize: 8),
        ),
      ),
    );
  }

  // Future<dynamic> bottomModal(BuildContext context, chatroom) {
  //   return showMaterialModalBottomSheet(
  //     context: context,
  //     builder: (context) => SingleChildScrollView(
  //       controller: ModalScrollController.of(context),
  //       child: BottomSheetModal(
  //         chat: chat[index],
  //         chatroom: chatroom,
  //         recipient: widget.recipient,
  //       ),
  //     ),
  //   );
  // }
}

class Spacer extends StatelessWidget {
  const Spacer({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: index == 0,
        child: SizedBox(
          height: 10,
        ));
  }
}
