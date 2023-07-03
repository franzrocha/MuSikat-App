import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String uid, sentBy, message;
  final Timestamp ts;
  List<String> seenBy;
  bool isDeleted;
  bool isEdited;

  Message(
      {this.uid = '',
      required this.sentBy,
      this.seenBy = const [],
      this.message = '',
      this.isDeleted = false,
      this.isEdited = false,
      ts})
      : ts = ts ?? Timestamp.now();

  static Message fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return Message(
      uid: snap.id,
      sentBy: json['sentBy'] ?? '',
      seenBy: json['seenBy'] != null
          ? List<String>.from(json['seenBy'])
          : <String>[],
      message: json['message'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      isEdited: json['isEdited'] ?? false,
      ts: json['ts'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> get json => {
        'sentBy': sentBy,
        'message': message,
        'seenBy': seenBy,
        'isDeleted': isDeleted,
        'isEdited': isEdited,
        'ts': ts,
      };

  static List<Message> fromQuerySnap(QuerySnapshot snap) {
    try {
      return snap.docs.map(Message.fromDocumentSnap).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  bool hasNotSeenMessage(String uid) {
    return !seenBy.contains(uid);
  }

  Future updateSeen(String userID, String chatroom, String recipient) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatroom)
        .collection('messages')
        .doc(uid)
        .update({
      'seenBy': FieldValue.arrayUnion([userID])
    }).then((value) => {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userID)
                  .collection('messageSnapshot')
                  .doc(chatroom)
                  .update({
                'seenBy': FieldValue.arrayUnion([userID])
              }),
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(recipient)
                  .collection('messageSnapshot')
                  .doc(chatroom)
                  .update({
                'seenBy': FieldValue.arrayUnion([userID])
              }),
            });
  }

  static Stream<List<Message>> currentChats(String chatroom) =>
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatroom)
          .collection('messages')
          .orderBy('ts')
          .snapshots()
          .map(Message.fromQuerySnap);

  Future updateMessage(String newMessage, String chatroom, String recipient) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatroom)
        .collection('messages')
        .doc(uid) //edited
        .update({'message': newMessage, 'isEdited': true}).then((value) => {
              if (chatroom != 'globalchat')
                {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('messageSnapshot')
                      .doc(chatroom)
                      .update({'message': newMessage}),
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(recipient)
                      .collection('messageSnapshot')
                      .doc(chatroom)
                      .update({'message': newMessage}),
                }
            });
  }

  Future deleteMessage(String chatroom, String recipient) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatroom)
        .collection('messages')
        .doc(uid) //edited
        .update({'isDeleted': true}).then((value) => {
              if (chatroom != 'globalchat')
                {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('messageSnapshot')
                      .doc(chatroom)
                      .update({'isDeleted': true}),
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(recipient)
                      .collection('messageSnapshot')
                      .doc(chatroom)
                      .update({'isDeleted': true}),
                }
            });
  }
}
