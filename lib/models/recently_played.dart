import 'package:cloud_firestore/cloud_firestore.dart';

class RecentlyPlayedModel {
  final String playedId, uid;
  final List<String> songId;

  RecentlyPlayedModel({
    required this.playedId,
    required this.uid,
    required this.songId,
  });

  static RecentlyPlayedModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return RecentlyPlayedModel(
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
<<<<<<< 962eefe0396b452f52b6ae3f13c042287f85eee8:lib/models/recently_played.dart

  static Future<void> addRecentlyPlayedSong(
      String userId, String songId) async {
    final collectionRef =
        FirebaseFirestore.instance.collection('recentlyPlayed');

    final querySnapshot =
        await collectionRef.where('uid', isEqualTo: userId).get();
    if (querySnapshot.docs.isEmpty) {
      final docRef = collectionRef.doc();
      final recentlyPlayedModel = RecentlyPlayedModel(
        playedId: docRef.id,
        uid: userId,
        songId: [songId],
      );
      await docRef.set(recentlyPlayedModel.json);
    } else {
      final docRef = querySnapshot.docs.first.reference;
      final recentSnap = await docRef.get();
      final recentModel = RecentlyPlayedModel.fromDocumentSnap(recentSnap);
      recentModel.songId.add(songId);
      await docRef.update(recentModel.json);
    }
  }

  static Future<List<SongModel>> getRecentlyPlayed() async {
    List<SongModel> likedSongs = [];
    final SongsController songCon = SongsController();
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final collectionRef =
          FirebaseFirestore.instance.collection('recentlyPlayed');
      final querySnapshot =
          await collectionRef.where('uid', isEqualTo: uid).get();
      for (var i = querySnapshot.docs.length - 1; i >= 0; i--) {
        final doc = querySnapshot.docs[i];
        final songIdList = List<String>.from(doc['songId'] as List<dynamic>);
        for (final songId in songIdList) {
          final song = await songCon.getSongById(songId);
          likedSongs.add(song);
        }
      }
      return likedSongs;
    } catch (e) {
      print(e.toString());
      return likedSongs;
    }
  }

 static Future<List<SongModel>> getRecommendedSongs(
  {bool byGenre = true}) async {
  try {
    // Retrieve the list of recently played songs for the current user
    final List<SongModel> recentlyPlayed =
        await RecentlyPlayedModel.getRecentlyPlayed();

    if (recentlyPlayed.isEmpty) {
      // If there are no recently played songs, return an empty list
      return [];
    }

    // Extract the genres or artists of the recently played songs
    final List<String> categories = [];
    for (final song in recentlyPlayed) {
      categories.add(byGenre ? song.genre : song.artist);
    }

    // Query for similar songs based on the extracted genres or artists
    final SongsController songsController = SongsController();
    Query query = FirebaseFirestore.instance.collection('songs');
    query = query.where(byGenre ? 'genre' : 'artist', whereIn: categories);
    print(categories);

    final QuerySnapshot querySnapshot = await query.get();
    print(querySnapshot.docs.length); 

    // Convert the query results to a list of SongModel objects
    final List<SongModel> recommendedSongs = [];
    for (final doc in querySnapshot.docs) {
      final song = await songsController.getSongById(doc.id);
      recommendedSongs.add(song);
    }

    // Shuffle the recommended songs and take the first 5
    recommendedSongs.shuffle();
    final List<SongModel> limitedRecommendedSongs =
        recommendedSongs.take(5).toList();

    return limitedRecommendedSongs;
  } catch (e) {
    print(e.toString());
    return [];
  }
}


  
=======
>>>>>>> modified ui in home screen:lib/models/listening_history_model.dart
}


