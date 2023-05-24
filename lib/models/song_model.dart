import 'package:cloud_firestore/cloud_firestore.dart';

class SongModel {
  final String songId, title, artist, fileName, audio, albumCover, genre, uid;
  final DateTime createdAt;
  final List<String> writers, producers, languages, description;
  final int playCount, likeCount;
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
    required this.playCount,
    required this.likeCount,
  });

  static SongModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = {};
    if (snap.data() != null) {
      json = snap.data() as Map<String, dynamic>;
    }
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongModel && other.songId == songId && other.title == title;
  }

  @override
  int get hashCode => songId.hashCode ^ title.hashCode;

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
}
