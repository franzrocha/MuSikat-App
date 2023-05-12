import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/chat_message_model.dart';
import 'package:musikat_app/models/chatroom_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

class IndividualChatController with ChangeNotifier {
  late StreamSubscription _chatSub;
  List<ChatMessage> chats = [];
  UserModel? user;
  final StreamController<String?> _controller = StreamController();
  Stream<String?> get stream => _controller.stream;
  String? chatroom;
  late String recipient;

  IndividualChatController() {
    _chatSub = const Stream.empty().listen((_) {});
    if (chatroom != null) {
      subscribe();
    } else {
      _controller.add("empty");
    }
  }

  subscribe() {
    _chatSub =
        ChatMessage.individualCurrentChats(chatroom!).listen(chatUpdateHandler);
    _controller.add("success");
  }

  @override
  void dispose() {
    _chatSub.cancel();
    super.dispose();
  }

  initChatRoom(String room, String currentRecipient) {
    UserModel.fromUid(uid: FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      recipient = currentRecipient;
      user = value;
      if (user != null && user!.chatrooms.contains(room)) {
        subscribe();
      } else {
        _controller.add("empty");
      }
      chatroom = room;
    });
  }

  generateRoomId(recipient) {
    String currentUser = FirebaseAuth.instance.currentUser!.uid;

    if (currentUser.codeUnits[0] >= recipient.codeUnits[0]) {
      if (currentUser.codeUnits[1] == recipient.codeUnits[1]) {
        return chatroom = recipient + currentUser;
      }
      return chatroom = currentUser + recipient;
    }
    return chatroom = recipient + currentUser;
  }

  Future<dynamic> getCurrentChats() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
    } on FirebaseAuthException catch (error) {
      print(error);
    }
  }

  getChatRooms(List<String> userChatRooms) {
    try {
      var data = [];

      FirebaseFirestore.instance
          .collection('chats')
          .where("chatroom", whereIn: userChatRooms)
          .get()
          .then((value) => {
                for (var item in value.docs) {data.add(item.data())}
              });
      return data;
    } catch (error) {
      print(error);
    }
  }

  chatUpdateHandler(List<ChatMessage> update) {
    for (ChatMessage message in update) {
      if (message.sentBy == FirebaseAuth.instance.currentUser!.uid &&
          chatroom == generateRoomId(recipient) &&
          message.hasNotSeenMessage(FirebaseAuth.instance.currentUser!.uid)) {
        message.individualUpdateSeen(
            FirebaseAuth.instance.currentUser!.uid, chatroom!);
      }
    }

    chats = update;
    notifyListeners();
  }

  sendFirstMessage(String message, String recipient) {
    ChatRoomModel chatRoom = ChatRoomModel(
      roomId: generateRoomId(recipient),
      participantIds: [recipient, FirebaseAuth.instance.currentUser!.uid],
    );

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoom.roomId)
        .set(chatRoom.json)
        .then((value) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoom.roomId)
          .collection('messages')
          .add(ChatMessage(
            sentBy: FirebaseAuth.instance.currentUser!.uid,
            message: message,
          ).json)
          .then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'chatrooms': FieldValue.arrayUnion([chatRoom.roomId])
        }).then((value) {
          FirebaseFirestore.instance.collection('users').doc(recipient).update({
            'chatrooms': FieldValue.arrayUnion([chatRoom.roomId])
          }).then((value) {
            subscribe();
          });
        });
      });
    });

    return chatRoom.roomId;
  }

  Future sendMessage({required String message}) async {
    return await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatroom)
        .collection('messages')
        .add(ChatMessage(
                sentBy: FirebaseAuth.instance.currentUser!.uid,
                message: message)
            .json);
  }
}
