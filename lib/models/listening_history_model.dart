import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';

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


}
