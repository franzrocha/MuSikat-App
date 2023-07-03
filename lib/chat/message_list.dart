import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/chat/message_model.dart';
import 'package:musikat_app/models/user_model.dart';

class MessageListController with ChangeNotifier {
  late StreamSubscription _messagesSub;
  final StreamController<String?> _controller = StreamController();
  Stream<String?> get stream => _controller.stream;
  UserModel user;
  List<Message> messages = [];
  List<UserModel> users = [];
  List<String> chatrooms = [];
  String? chatroom;

  MessageListController(this.user) {
    fetchChatrooms();
    try {
      // var somedata = activeChats();
      // shit();
    } catch (e) {
      print('errrrrrrrrrrrrrrrrrror');
      print(e);
    }
  }

  static Stream<void> activeChats() => FirebaseFirestore.instance
      .collection('chats')
      .snapshots()
      .map(fromQuerySnap);

  static fromQuerySnap(QuerySnapshot snap) {
    try {
      print(snap.docs);
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future fetchChatrooms() {
    return UserModel.fromUid(uid: FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      return value;
    }).then((dynamic user) {
      return FirebaseFirestore.instance
          .collection("users")
          .where("chatrooms", arrayContainsAny: user?.chatrooms ?? [])
          .get()
          .then((value) {
        List<UserModel> currentUserMsgList = [];
        for (var data in value.docs) {
          currentUserMsgList.add(UserModel.fromDocumentSnap(data));
        }
        users = currentUserMsgList;
        return currentUserMsgList;
      });
    });
  }

  @override
  void dispose() {
    _messagesSub.cancel();
    super.dispose();
  }

  chatUpdateHandler(List<Message> update) {
    messages = update;
    notifyListeners();
  }

  Future sendMessage({required String message}) {
    return FirebaseFirestore.instance.collection('chats').add(Message(
            sentBy: FirebaseAuth.instance.currentUser!.uid, message: message)
        .json);
  }
}
