import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String uid, sentBy, message;
  final Timestamp ts;
  String? previousChatID;
  List<String> seenBy;
  bool isDeleted;
  bool isEdited;

  ChatMessage(
      {this.uid = '',
      required this.sentBy,
      this.seenBy = const [],
      this.message = '',
      this.isDeleted = false,
      this.isEdited = false,
      ts})
      : ts = ts ?? Timestamp.now();

  static ChatMessage fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return ChatMessage(
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



  static List<ChatMessage> fromQuerySnap(QuerySnapshot snap) {
    try {
      return snap.docs.map(ChatMessage.fromDocumentSnap).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  String get previousMessage {
    return previousChatID!;
  }

  bool hasNotSeenMessage(String uid) {
    return !seenBy.contains(uid);
  }

  Future updateSeen(String userID) {
    return FirebaseFirestore.instance.collection("chats").doc(uid).update({
      'seenBy': FieldValue.arrayUnion([userID])
    });
  }

  static Stream<List<ChatMessage>> currentChats() => FirebaseFirestore.instance
      .collection('chats')
      .orderBy('ts')
      .snapshots()
      .map(ChatMessage.fromQuerySnap);

  Future updateMessage(String newMessage) {
    return FirebaseFirestore.instance.collection("chats").doc(uid) //edite  d
        .update({'message': newMessage, 'isEdited': true});
  }

  Future deleteMessage() {
    return FirebaseFirestore.instance.collection("chats").doc(uid) //edite  d
        .update({'message': 'message deleted', 'isDeleted': true});
  }
}