import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid, username, email, image;
  Timestamp created, updated;

  ChatUser(this.uid, this.username, this.email, this.image, this.created, this.updated);

  static ChatUser fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return ChatUser(
      snap.id,
      json['username'] ?? '',
      json['email'] ?? '',
      json['image'] ?? '',
      json['created'] ?? Timestamp.now(),
      json['updated'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> get json => {
        'uid': uid,
        'username': username,
        'email': email,
        'image': image,
        'created': created,
        'updated': updated
      };

  static Future<ChatUser> fromUid({required String uid}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return ChatUser.fromDocumentSnap(snap);
  }

  static Stream<ChatUser> fromUidStream({required String uid}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(ChatUser.fromDocumentSnap);
  }
}
