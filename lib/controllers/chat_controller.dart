import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/models/chat_message_model.dart';

class ChatController with ChangeNotifier {
  late StreamSubscription _chatSub;
  List<ChatMessage> chats = [];
  String? previousChatID;

  ChatController() {
    _chatSub = ChatMessage.currentChats().listen(chatUpdateHandler);
  }

  @override
  void dispose() {
    _chatSub.cancel();
    super.dispose();
  }

  chatUpdateHandler(List<ChatMessage> update) {
    for (ChatMessage message in update) {
      if (message.hasNotSeenMessage(FirebaseAuth.instance.currentUser!.uid)) {
        message.updateSeen(FirebaseAuth.instance.currentUser!.uid);
      }
    }
    chats = update;
    notifyListeners();
  }

  Future sendMessage({required String message}) {
    return FirebaseFirestore.instance.collection('chats').add(ChatMessage(
            sentBy: FirebaseAuth.instance.currentUser!.uid, message: message)
        .json);
  }
}
