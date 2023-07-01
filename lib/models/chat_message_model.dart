import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String uid, sentBy, message;
  final Timestamp ts;
  String? previousChatID;
  List<String> seenBy;
  bool isDeleted;
  bool isEdited;

  ChatMessage({
    this.uid = '',
    required this.sentBy,
    this.seenBy = const [],
    this.message = '',
    this.isDeleted = false,
    this.isEdited = false,
    ts,
  }) : ts = ts ?? Timestamp.now();

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

  static ChatMessage fromDocumentSnapWithRoomId(
      DocumentSnapshot snap, String roomId) {
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
        'ts': ts,
      };

  static List<ChatMessage> fromQuerySnap(QuerySnapshot snap) {
    try {
      return snap.docs.map(ChatMessage.fromDocumentSnap).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // String get previousMessage {
  //   return previousChatID!;
  // }

  bool hasNotSeenMessage(String uid) {
    return !seenBy.contains(uid);
  }

  Future individualUpdateSeen(String userID, String chatroom) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatroom)
        .collection('messages')
        .doc(uid)
        .update({
      'seenBy': FieldValue.arrayUnion([userID])
    });
  }

  Future updateSeen(String userID) async {
    final globalChatRef =
        FirebaseFirestore.instance.collection('chats').doc('globalChat');
    await globalChatRef.collection('messages').doc(uid).update({
      'seenBy': FieldValue.arrayUnion([userID]),
    });
  }

  static Stream<List<ChatMessage>> currentChats() {
    final globalChatRef =
        FirebaseFirestore.instance.collection('chats').doc('globalChat');
    return globalChatRef.collection('messages').orderBy('ts').snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map((doc) =>
                ChatMessage.fromDocumentSnapWithRoomId(doc, 'globalChat'))
            .toList());
  }

  static Stream<List<ChatMessage>> individualCurrentChats(String chatroom) =>
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatroom)
          .collection('messages')
          .orderBy('ts')
          .snapshots()
          .map(ChatMessage.fromQuerySnap);
          

  Future updateMessage(String newMessage) async {
    final globalChatRef =
        FirebaseFirestore.instance.collection('chats').doc('globalChat');
    await globalChatRef.collection('messages').doc(uid).update({
      'message': newMessage,
      'isEdited': true,
    });
  }

  Future individualUpdateMessage(String newMessage, String chatroom) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatroom)
        .collection('messages')
        .doc(uid)
        .update({'message': newMessage, 'isEdited': true});
  }

  Future deleteMessage() async {
    final globalChatRef =
        FirebaseFirestore.instance.collection('chats').doc('globalChat');
    await globalChatRef.collection('messages').doc(uid).update({
      'message': 'message deleted',
      'isDeleted': true,
    });
  }

  Future individualDeleteMessage(String chatroom) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatroom)
        .collection('messages')
        .doc(uid) 
        .update({'isDeleted': true});
  }
}