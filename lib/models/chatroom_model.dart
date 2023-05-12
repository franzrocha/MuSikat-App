import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String roomId;
  final List<String> participantIds;

  ChatRoomModel({
    required this.roomId,
    required this.participantIds,
  });

  // Define method to get reference to chat messages subcollection
  // CollectionReference get messageCollection =>
  //     FirebaseFirestore.instance.collection('chats/$roomId/messages');

  static ChatRoomModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return ChatRoomModel(
      roomId: snap.id,
      participantIds: List<String>.from(json['participantIds']),
    );
  }

  Map<String, dynamic> get json => {
        'roomId': roomId,
        'participantIds': participantIds,
      };
}
