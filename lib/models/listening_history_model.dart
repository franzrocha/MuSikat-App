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
<<<<<<< 962eefe0396b452f52b6ae3f13c042287f85eee8:lib/models/recently_played.dart

  static Future<void> addListeningHistorySong(
      String userId, String songId) async {
    final collectionRef =
        FirebaseFirestore.instance.collection('listeningHistory');

    final querySnapshot =
        await collectionRef.where('uid', isEqualTo: userId).get();
    if (querySnapshot.docs.isEmpty) {
      final docRef = collectionRef.doc();
      final recentlyPlayedModel = ListeningHistoryModel(
        playedId: docRef.id,
        uid: userId,
        songId: [songId],
      );
      await docRef.set(recentlyPlayedModel.json);
    } else {
      final docRef = querySnapshot.docs.first.reference;
      final recentSnap = await docRef.get();
      final recentModel = ListeningHistoryModel.fromDocumentSnap(recentSnap);

      if (recentModel.songId.contains(songId)) {
        recentModel.songId.remove(songId);
      }

      recentModel.songId.insert(0, songId);

      await docRef.update(recentModel.json);
    }
  }


<<<<<<< HEAD:lib/models/recently_played.dart
  
=======
>>>>>>> modified ui in home screen:lib/models/listening_history_model.dart
=======
>>>>>>> main:lib/models/listening_history_model.dart
}
