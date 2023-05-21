import 'package:cloud_firestore/cloud_firestore.dart';

class ListeningHistoryModel {
  final String playedId, uid;
  final List<String> songId;

  ListeningHistoryModel({
    required this.playedId,
    required this.uid,
    required this.songId,
  });

  static ListeningHistoryModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return ListeningHistoryModel(
      playedId: snap.id,
      uid: json['uid'] ?? '',
      songId: (json['songId'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> get json => {
        'playedId': playedId,
        'uid': uid,
        'songId': songId,
      };

}
