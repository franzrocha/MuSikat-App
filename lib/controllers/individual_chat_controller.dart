import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/chat_message_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

class IndividualChatController with ChangeNotifier {
  late StreamSubscription _chatSub;
  UserModel? user;
  final StreamController<String?> _controller = StreamController();
  Stream<String?> get stream => _controller.stream;
  String? chatroom;
  late String recipient;
  List<ChatMessage> messages = [];

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
      if (chatroom == generateRoomId(recipient) &&
          message.hasNotSeenMessage(FirebaseAuth.instance.currentUser!.uid)) {
        message.individualUpdateSeen(
            FirebaseAuth.instance.currentUser!.uid, chatroom!);
      } else {}
    }

    messages = update;
    notifyListeners();
  }

  sendFirstMessage({
    String message = '',
    required String recipient,
  }) {
    var newMessage = ChatMessage(
            sentBy: FirebaseAuth.instance.currentUser!.uid, message: message)
        .json;

    var thisUser = FirebaseAuth.instance.currentUser!.uid;
    String chatroom = generateRoomId(recipient);

    firstMessageText(chatroom, recipient, thisUser, newMessage);
  }

  void firstMessageText(String chatroom, String recipient, String thisUser,
      Map<String, dynamic> newMessage) {
    FirebaseFirestore.instance.collection('chats').doc(chatroom).set({
      'chatroom': chatroom,
      'members': FieldValue.arrayUnion([recipient, thisUser])
    }).then(
      (snap) => {
        FirebaseFirestore.instance
            .collection('chats')
            .doc(chatroom)
            .collection('messages')
            .add(newMessage)
            .then((value) => {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    'chatrooms': FieldValue.arrayUnion([chatroom])
                  }).then((value) => {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(recipient)
                                .update({
                              'chatrooms': FieldValue.arrayUnion([chatroom])
                            }),
                            subscribe(),
                          }),
                }),
      },
    );
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

  Future<List<UserModel>> fetchChatrooms() async {
    UserModel user =
        await UserModel.fromUid(uid: FirebaseAuth.instance.currentUser!.uid);

    List<String> chatrooms = user.chatrooms;
    if (chatrooms.isEmpty) {
      return [];
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("chatrooms", arrayContainsAny: chatrooms)
        .get();

    List<UserModel> users = [];
    for (var documentSnapshot in querySnapshot.docs) {
      users.add(UserModel.fromDocumentSnap(documentSnapshot));
    }

    return users;
  }

  Stream<List<UserModel>> fetchChatroomsStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      List<UserModel> users = await fetchChatrooms();

      if (users.isNotEmpty) {
        yield users;
      }
    }
  }
}
