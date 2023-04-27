import 'package:cloud_firestore/cloud_firestore.dart';

class LikedSongsModel {
  final String likedSongsId, uid;
  final List<String> songId;

  LikedSongsModel({
    required this.likedSongsId,
    required this.uid,
    required this.songId,
  });

  static LikedSongsModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return LikedSongsModel(
      likedSongsId: snap.id,
      uid: json['uid'] ?? '',
      songId: (json['songId'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> get json => {
        'likedSongsId': likedSongsId,
        'uid': uid,
        'songId': songId,
      };
}
