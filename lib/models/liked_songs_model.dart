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

  static Future<List<SongModel>> getRecommendedSongsByLike(
      {bool byGenre = true}) async {
    try {
      final LikedSongsController likedCon = LikedSongsController();

      final List<SongModel> likedSongs = await likedCon.getLikedSongs();

      if (likedSongs.isEmpty) {
        return [];
      }

      final List<String> categories = [];
      for (final song in likedSongs) {
        categories.add(byGenre ? song.genre : song.artist);
      }

      final SongsController songsController = SongsController();
      Query query = FirebaseFirestore.instance.collection('songs');
      if (categories.isNotEmpty) {
        query = query.where(byGenre ? 'genre' : 'artist', whereIn: categories);
        // print('Print me $categories');
      }

      final QuerySnapshot querySnapshot = await query.get();
      print(querySnapshot.docs.length);

      final List<SongModel> recommendedSongs = [];
      for (final doc in querySnapshot.docs) {
        final song = await songsController.getSongById(doc.id);
        recommendedSongs.add(song);
      }

      recommendedSongs.shuffle();
      final List<SongModel> limitedRecommendedSongs =
          recommendedSongs.take(5).toList();

      return limitedRecommendedSongs;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}
