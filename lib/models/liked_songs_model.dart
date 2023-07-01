import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';

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


  static Future<List<SongModel>> getRecommendedSongsByLike() async {
  try {
    final LikedSongsController likedCon = LikedSongsController();

    final List<SongModel> likedSongs = await likedCon.getLikedSongs();

    if (likedSongs.isEmpty) {
      return [];
    }

    final List<String> categories = [];
    for (final song in likedSongs) {
      categories.add(song.genre);
    }

    final SongsController songsController = SongsController();
    final List<SongModel> recommendedSongs = [];

    const int chunkSize = 10;
    final int numChunks = (categories.length / chunkSize).ceil();

    for (int i = 0; i < numChunks; i++) {
      final List<String> chunk = categories.sublist(
          i * chunkSize,
          (i + 1) * chunkSize > categories.length
              ? categories.length
              : (i + 1) * chunkSize);

      Query query = FirebaseFirestore.instance.collection('songs');
      query = query.where('genre', whereIn: chunk);

      query = query.orderBy('__name__');

      query = query.limit(10);

      final QuerySnapshot querySnapshot = await query.get();

      for (final doc in querySnapshot.docs) {
        final song = await songsController.getSongById(doc.id);
        recommendedSongs.add(song);
      }
    }

    recommendedSongs.shuffle();

    return recommendedSongs;
  } catch (e) {
    print(e.toString());
    return [];
  }
}

}
