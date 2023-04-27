import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/liked_songs_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikedSongsController with ChangeNotifier {
  final bool _isLiked = false;
  final SongsController _songCon = SongsController();

  bool get isLiked => _isLiked;

  Future<void> addLikedSong(String userId, String songId) async {
    final collectionRef = FirebaseFirestore.instance.collection('likedSongs');

    // Get the document for this user's liked songs
    final querySnapshot =
        await collectionRef.where('uid', isEqualTo: userId).get();

    if (querySnapshot.docs.isEmpty) {
      // There is no document for this user's liked songs yet, so create a new one
      final docRef = collectionRef.doc();
      final likedSongsModel = LikedSongsModel(
        likedSongsId: docRef.id,
        uid: userId,
        songId: [songId],
      );
      await docRef.set(likedSongsModel.json);
    } else {
      // Update the existing document to add the newly liked song to the songId array
      final docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'songId': FieldValue.arrayUnion([songId]),
      });
    }
    notifyListeners();
  }

  Future<void> removeLikedSong(String userId, String songId) async {
    final collectionRef = FirebaseFirestore.instance.collection('likedSongs');

    // Get the document for this user's liked songs
    final querySnapshot =
        await collectionRef.where('uid', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update the existing document to remove the unliked song from the songId array
      final docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'songId': FieldValue.arrayRemove([songId]),
      });

      // Check if there are no more songIds left in the document, and delete it if so
      final updatedSnapshot = await docRef.get();
      final updatedLikedSongsModel =
          LikedSongsModel.fromDocumentSnap(updatedSnapshot);
      if (updatedLikedSongsModel.songId.isEmpty) {
        await docRef.delete();
      }
    }
    notifyListeners();
  }

  Future<bool> isSongLikedByUser(String songId, String userId) async {
    final collectionRef = FirebaseFirestore.instance.collection('likedSongs');
    // Get the document for this user's liked songs
    final querySnapshot =
        await collectionRef.where('uid', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Check if the songId is present in the document's songId array
      final docData = querySnapshot.docs.first.data();
      if (docData.containsKey('songId') && docData['songId'].contains(songId)) {
        return true;
      }
    }

    return false;
  }

  Future<List<Map<String, dynamic>>> getLikedSongs() async {
    List<Map<String, dynamic>> likedSongs = [];
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final collectionRef = FirebaseFirestore.instance.collection('likedSongs');
      final querySnapshot =
          await collectionRef.where('uid', isEqualTo: uid).get();

      for (final doc in querySnapshot.docs) {
        final songIdList = List<String>.from(doc['songId'] as List<dynamic>);
        for (final songId in songIdList) {
          final song = await _songCon.getSongById(songId);
          final songData = {
            'id': doc.id,
            'title': song.title,
            'artist': song.artist,
            'albumCover': song.albumCover,
            'audio': song.audio,
          };
          likedSongs.add(songData);
        }
      }
      return likedSongs;
    } catch (e) {
      print(e.toString());
      return likedSongs;
    }
  }
}
