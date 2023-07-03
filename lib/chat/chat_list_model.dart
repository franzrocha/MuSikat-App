import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatList {
  final String uid, sentBy, message;
  final Timestamp ts;
  List<String> seenBy;
  bool isDeleted;
  bool isEdited;

  ChatList(
      {this.uid = '',
      required this.sentBy,
      this.seenBy = const [],
      this.message = '',
      this.isDeleted = false,
      this.isEdited = false,
      ts})
      : ts = ts ?? Timestamp.now();

  static ChatList fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return ChatList(
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
        'ts': ts
      };

  static List<ChatList> fromQuerySnap(QuerySnapshot snap) {
    try {
      return snap.docs.map(ChatList.fromDocumentSnap).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Stream<List<ChatList>> currentChats() => FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('messageSnapshot')
      .orderBy('ts')
      .snapshots()
      .map(ChatList.fromQuerySnap);
}