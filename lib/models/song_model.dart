import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikat_app/controllers/songs_controller.dart';

class SongModel {
  final String songId, title, artist, fileName, audio, albumCover, genre, uid;
  final DateTime createdAt;
  final List<String> writers, producers, languages, description;
  final int playCount; // Added field
  final int likeCount;
  SongModel({
    required this.songId,
    required this.title,
    required this.artist,
    required this.fileName,
    required this.audio,
    required this.albumCover,
    required this.createdAt,
    required this.writers,
    required this.producers,
    required this.genre,
    required this.uid,
    required this.languages,
    required this.description,
    required this.playCount, // Added field
    required this.likeCount,
  });

  set rank(int rank) {}

  set isLiked(bool isLiked) {}

  static SongModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;

    return SongModel(
      songId: snap.id,
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      fileName: json['file_name'] ?? '',
      audio: json['audio'] ?? '',
      albumCover: json['album_cover'] ?? '',
      createdAt: json['created_at']?.toDate() ?? DateTime.now(),
      writers: (json['writers'] as List<dynamic>?)?.cast<String>() ?? [],
      producers: (json['producers'] as List<dynamic>?)?.cast<String>() ?? [],
      genre: json['genre'] ?? '',
      uid: json['uid'] ?? '',
      languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      description:
          (json['description'] as List<dynamic>?)?.cast<String>() ?? [],
      playCount: json['playCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> get json => {
        'songId': songId,
        'title': title,
        'artist': artist,
        'fileName': fileName,
        'audio': audio,
        'album_cover': albumCover,
        'createdAt': createdAt,
        'writers': writers,
        'producers': producers,
        'genre': genre,
        'uid': uid,
        'languages': languages,
        'description': description,
        'playCount': playCount,
        'likeCount': likeCount,
      };

  static Future<List<SongModel>> getSongs() async {
    List<SongModel> songs = [];
    await FirebaseFirestore.instance
        .collection('songs')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        songs.add(SongModel.fromDocumentSnap(doc));
      }
    });

    return songs;
  }

  searchTitle(String song) {
    return title.toLowerCase().contains(song.toLowerCase());
  }

  static Future<SongModel> fromUid({required String uid}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('songs').doc(uid).get();
    return SongModel.fromDocumentSnap(snap);
  }
}
