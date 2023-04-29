import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String playlistId, title, description, playlistImg, uid;
  final DateTime createdAt;
  final List<String> songs;

  PlaylistModel({
    required this.playlistId,
    required this.title,
    required this.description,
    required this.playlistImg,
    required this.createdAt,
    required this.songs,
    required this.uid,
  });

  static PlaylistModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;

    return PlaylistModel(
      playlistId: snap.id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      playlistImg: json['playlistImg'] ?? '',
      createdAt: json['created_at']?.toDate() ?? DateTime.now(),
      songs: (json['songs'] as List<dynamic>?)?.cast<String>() ?? [],
      uid: json['uid'] ?? '',
    );
  }

  Map<String, dynamic> get json => {
        'playlistId': playlistId,
        'title': title,
        'description': description,
        'playlistImg': playlistImg,
        'createdAt': createdAt,
        'songs': songs,
        'uid': uid,
      };
}