import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/listening_history_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/utils/exports.dart';

class ListeningHistoryController with ChangeNotifier {
  Stream<List<SongModel>> getListeningHistoryStream() {
    final SongsController songCon = SongsController();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final collectionRef =
        FirebaseFirestore.instance.collection('listeningHistory');

    return collectionRef
        .where('uid', isEqualTo: uid)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<SongModel> likedSongs = [];

      for (var i = querySnapshot.docs.length - 1; i >= 0; i--) {
        final doc = querySnapshot.docs[i];
        final songIdList = List<String>.from(doc['songId'] as List<dynamic>);

        for (final songId in songIdList) {
          final song = await songCon.getSongById(songId);
          likedSongs.add(song);
        }
      }

      return likedSongs;
    });
  }

<<<<<<< HEAD
  Stream<List<SongModel>> getRecommendedSongsStream() {
    final StreamController<List<SongModel>> controller =
        StreamController<List<SongModel>>();

    void fetchRecommendedSongs(List<SongModel> recentlyPlayed) async {
      try {
        if (recentlyPlayed.isEmpty) {
          controller.add([]);
          return;
        }

        final List<String> categories = [];
        for (final song in recentlyPlayed) {
          categories.add(song.genre);
        }

        final List<List<String>> categoryChunks = [];
        for (int i = 0; i < categories.length; i += 10) {
          final chunk = categories.sublist(
              i, i + 10 < categories.length ? i + 10 : categories.length);
          categoryChunks.add(chunk);
        }

        final SongsController songsController = SongsController();
        final List<Query> queries = categoryChunks.map((chunk) {
          Query query = FirebaseFirestore.instance.collection('songs');
          query = query.where('genre', whereIn: chunk);
          return query;
        }).toList();

        final List<QuerySnapshot> querySnapshots =
            await Future.wait(queries.map((query) => query.get()));
        final List<QueryDocumentSnapshot> allDocs =
            querySnapshots.expand((snapshot) => snapshot.docs).toList();

        final List<SongModel> recommendedSongs = [];
        for (final doc in allDocs) {
          final song = await songsController.getSongById(doc.id);
          recommendedSongs.add(song);
        }

        recommendedSongs.shuffle();
        final List<SongModel> limitedRecommendedSongs =
            recommendedSongs.take(5).toList();

        controller.add(limitedRecommendedSongs);
      } catch (e) {
        print(e.toString());
        controller.add([]);
      }
    }

    getListeningHistoryStream().listen((recentlyPlayed) {
      fetchRecommendedSongs(recentlyPlayed);
    });

    return controller.stream;
  }

=======
 Stream<List<SongModel>> getRecommendedSongsStream() {
  final StreamController<List<SongModel>> controller =
      StreamController<List<SongModel>>();

  void fetchRecommendedSongs(List<SongModel> recentlyPlayed) async {
    try {
      if (recentlyPlayed.isEmpty) {
        controller.add([]);
        return;
      }

      final List<String> categories = [];
      for (final song in recentlyPlayed) {
        categories.add(song.genre);
      }

      final List<List<String>> categoryChunks = [];
      for (int i = 0; i < categories.length; i += 10) {
        final chunk = categories.sublist(
            i, i + 10 < categories.length ? i + 10 : categories.length);
        categoryChunks.add(chunk);
      }

      final SongsController songsController = SongsController();
      final List<Query> queries = categoryChunks.map((chunk) {
        Query query = FirebaseFirestore.instance.collection('songs');
        query = query.where('genre', whereIn: chunk);
        return query;
      }).toList();

      final List<QuerySnapshot> querySnapshots =
          await Future.wait(queries.map((query) => query.get()));
      final List<QueryDocumentSnapshot> allDocs =
          querySnapshots.expand((snapshot) => snapshot.docs).toList();

      final List<SongModel> recommendedSongs = [];
      for (final doc in allDocs) {
        final song = await songsController.getSongById(doc.id);
        recommendedSongs.add(song);
      }

      recommendedSongs.shuffle();
      final List<SongModel> limitedRecommendedSongs =
          recommendedSongs.take(5).toList();

      controller.add(limitedRecommendedSongs);
    } catch (e) {
      print(e.toString());
      controller.add([]);
    }
  }

  getListeningHistoryStream().listen((recentlyPlayed) {
    fetchRecommendedSongs(recentlyPlayed);
  });

  return controller.stream;
}

>>>>>>> main
  Future<void> deleteListeningHistory(String userId) async {
    final collectionRef =
        FirebaseFirestore.instance.collection('listeningHistory');

    final querySnapshot =
        await collectionRef.where('uid', isEqualTo: userId).get();
    if (querySnapshot.docs.isNotEmpty) {
      final docRef = querySnapshot.docs.first.reference;
      final recentSnap = await docRef.get();
      final recentModel = ListeningHistoryModel.fromDocumentSnap(recentSnap);

<<<<<<< HEAD
      recentModel.songId.clear();

=======
      // Clear the songId list
      recentModel.songId.clear();

      // Update the document with the modified song list
>>>>>>> main
      await docRef.update(recentModel.json);
    }
  }

<<<<<<< HEAD
  Future<void> addListeningHistorySong(
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
=======

>>>>>>> main
}
