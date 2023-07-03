import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/listening_history_model.dart';
import 'package:musikat_app/models/playlist_model.dart';
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

  Future<List<SongModel>> getRecommendedSongsBasedOnGenre() async {
    try {
      final List<SongModel> recentlyPlayed = await getListeningHistory();

      if (recentlyPlayed.isEmpty) {
        return [];
      }

      final List<String> categories = [];
      final Set<String> addedSongs = <String>{};

      for (final song in recentlyPlayed) {
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
              : (i + 1) * chunkSize,
        );

        Query query = FirebaseFirestore.instance.collection('songs');
        query = query.where('genre', whereIn: chunk);

        final QuerySnapshot querySnapshot = await query.get();

        for (final doc in querySnapshot.docs) {
          final song = await songsController.getSongById(doc.id);

          if (!addedSongs.contains(song.songId)) {
            recommendedSongs.add(song);
            addedSongs.add(song.songId);
          }
        }
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

  Future<List<SongModel>> getRecommendedSongsBasedOnLanguage() async {
    try {
      final List<SongModel> recentlyPlayed = await getListeningHistory();

      if (recentlyPlayed.isEmpty) {
        return [];
      }

      final List<String> categories = [];
      final Set<String> addedSongs = <String>{};

      for (final song in recentlyPlayed) {
        categories.addAll(song.languages);
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
        query = query.where('languages', arrayContainsAny: chunk);

        final QuerySnapshot querySnapshot = await query.get();

        for (final doc in querySnapshot.docs) {
          final song = await songsController.getSongById(doc.id);

          if (!addedSongs.contains(song.songId)) {
            recommendedSongs.add(song);
            addedSongs.add(song.songId);
          }
        }
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

  Future<List<SongModel>> getRecommendedSongsBasedOnMoods() async {
    try {
      final List<SongModel> recentlyPlayed = await getListeningHistory();

      if (recentlyPlayed.isEmpty) {
        return [];
      }

      final List<String> categories = [];
      final Set<String> addedSongs = <String>{};

      for (final song in recentlyPlayed) {
        categories.addAll(song.description);
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
        query = query.where('description', arrayContainsAny: chunk);

        final QuerySnapshot querySnapshot = await query.get();

        for (final doc in querySnapshot.docs) {
          final song = await songsController.getSongById(doc.id);

          if (!addedSongs.contains(song.songId)) {
            recommendedSongs.add(song);
            addedSongs.add(song.songId);
          }
        }
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

  Future<List<PlaylistModel>> getRecommendedPlaylistBasedOnGenre() async {
  try {
    final List<SongModel> recentlyPlayed = await getListeningHistory();

    if (recentlyPlayed.isEmpty) {
      return [];
    }

    final List<String> categories = [];
    for (final song in recentlyPlayed) {
      categories.add(song.genre);
    }

    final PlaylistController playlistController = PlaylistController();
    final Set<String> playlistIds = {}; // Set to store unique playlist IDs
    final List<PlaylistModel> recommendedPlaylists = [];

    const int chunkSize = 10;
    final int numChunks = (categories.length / chunkSize).ceil();

    for (int i = 0; i < numChunks; i++) {
      final List<String> chunk = categories.sublist(
          i * chunkSize,
          (i + 1) * chunkSize > categories.length
              ? categories.length
              : (i + 1) * chunkSize);

      Query query = FirebaseFirestore.instance.collection('playlists');
      query = query.where('genre', whereIn: chunk);

      final QuerySnapshot querySnapshot = await query.get();

      for (final doc in querySnapshot.docs) {
        final playlistId = doc.id;
        if (!playlistIds.contains(playlistId)) {
          playlistIds.add(playlistId);

          final playlist = await playlistController.getPlaylistById(playlistId);
          recommendedPlaylists.add(playlist);
        }
      }
    }

    recommendedPlaylists.shuffle();
    final List<PlaylistModel> limitedRecommendedSongs =
        recommendedPlaylists.take(5).toList();

    return limitedRecommendedSongs;
  } catch (e) {
    print(e.toString());
    return [];
  }
}

}
