import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikedSongsController extends ChangeNotifier {
  final bool _isLiked = false;
  final SongsController _songCon = SongsController();

//  void loadIsLiked(String songId, SharedPreferences prefs) async {
//     _prefs = await SharedPreferences.getInstance();
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//     _isLiked = _prefs.getBool(uid + songId) ?? false;
//     notifyListeners();
//   }

  bool get isLiked => _isLiked;

   Future<void> addToLikedSongs(String songId) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      DocumentReference songRef = userRef.collection('likedSongs').doc(songId);
      DocumentSnapshot songSnap = await songRef.get();
      if (!songSnap.exists) {
        // Add song to liked songs subcollection
        SongModel song = await _songCon.getSongById(songId);
        await songRef.set({
          'title': song.title,
          'artist': song.artist,
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> removeLikedSong(String songId) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference songRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('likedSongs')
          .doc(songId);
      DocumentSnapshot songSnap = await songRef.get();
      if (songSnap.exists) {
        // Remove song from liked songs subcollection
        await songRef.delete();
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
