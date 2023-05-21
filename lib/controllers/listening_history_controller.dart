import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/listening_history_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/utils/exports.dart';

class ListeningHistoryController with ChangeNotifier {
  Future<List<SongModel>> getListeningHistory() async {
    List<SongModel> listenedSongs = [];
    final SongsController songCon = SongsController();
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final collectionRef =
          FirebaseFirestore.instance.collection('listeningHistory');
      final querySnapshot =
          await collectionRef.where('uid', isEqualTo: uid).get();
      for (var i = querySnapshot.docs.length - 1; i >= 0; i--) {
        final doc = querySnapshot.docs[i];
        final songIdList = List<String>.from(doc['songId'] as List<dynamic>);
        for (final songId in songIdList) {
          final song = await songCon.getSongById(songId);
          listenedSongs.add(song);
        }
      }
      return listenedSongs;
    } catch (e) {
      print(e.toString());
      return listenedSongs;
    }
  }

  Stream<List<SongModel>> getListeningHistoryStream() {
    final SongsController songCon = SongsController();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final collectionRef =
        FirebaseFirestore.instance.collection('listeningHistory');

    return collectionRef
        .where('uid', isEqualTo: uid)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<SongModel> listenedSongs = [];

      for (var i = querySnapshot.docs.length - 1; i >= 0; i--) {
        final doc = querySnapshot.docs[i];
        final songIdList = List<String>.from(doc['songId'] as List<dynamic>);

        for (final songId in songIdList) {
          final song = await songCon.getSongById(songId);
          listenedSongs.add(song);
        }
      }

      return listenedSongs;
    });
  }

  Future<void> deleteListeningHistory(String userId) async {
    final collectionRef =
        FirebaseFirestore.instance.collection('listeningHistory');

    final querySnapshot =
        await collectionRef.where('uid', isEqualTo: userId).get();
    if (querySnapshot.docs.isNotEmpty) {
      final docRef = querySnapshot.docs.first.reference;
      final recentSnap = await docRef.get();
      final recentModel = ListeningHistoryModel.fromDocumentSnap(recentSnap);

      recentModel.songId.clear();

      await docRef.update(recentModel.json);
    }
  }

  Future<void> addListeningHistorySong(String userId, String songId) async {
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

  Future<List<SongModel>> getRecommendedSongs() async {
    try {
      // Retrieve the list of recently played songs for the current user
      final List<SongModel> recentlyPlayed = await getListeningHistory();

      if (recentlyPlayed.isEmpty) {
        // If there are no recently played songs, return an empty list
        return [];
      }

      // Extract the genres or artists of the recently played songs
      final List<String> categories = [];
      for (final song in recentlyPlayed) {
        categories.add(song.genre);
      }

      // Query for similar songs based on the extracted genres or artists
      final SongsController songsController = SongsController();
      Query query = FirebaseFirestore.instance.collection('songs');
      query = query.where('genre', whereIn: categories);
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
}
