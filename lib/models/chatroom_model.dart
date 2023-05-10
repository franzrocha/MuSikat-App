import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String roomId;
  final List<String> participantIds;

  ChatRoom({
    required this.roomId,
    required this.participantIds,
  });

  // Define method to get reference to chat messages subcollection
  CollectionReference get messageCollection =>
      FirebaseFirestore.instance.collection('chats/$roomId/messages');

  static ChatRoom fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return ChatRoom(
      roomId: snap.id,
      participantIds: List<String>.from(json['participantIds']),
    );
  }

  Map<String, dynamic> get json => {
        'roomId': roomId,
        'participantIds': participantIds,
      };
}
