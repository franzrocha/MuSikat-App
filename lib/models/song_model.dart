import 'package:cloud_firestore/cloud_firestore.dart';

class SongModel {
  final String songId, title, fileName, audioLocation;
  final DateTime createdAt;

  SongModel({
    required this.songId,
    required this.title,
    required this.fileName,
    required this.audioLocation,
    required this.createdAt,
  });

  static SongModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return SongModel(
      songId: snap.id,
      title: json['title'] ?? '',
      fileName: json['file_name'] ?? '',
      audioLocation: json['audio_location'] ?? '',
      createdAt: json['created_at']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> get json => {
        'songId': songId,
        'title': title,
        'fileName': fileName,
        'audioLocation': audioLocation,
        'createdAt': createdAt,
      };
}
