import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:musikat_app/models/song_model.dart';

class SongsController with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StreamController<double> _uploadProgressStreamController =
      StreamController<double>();

  Future<SongModel> getSongById(String songId) async {
    final DocumentSnapshot snap =
        await _db.collection('songs').doc(songId).get();
    return SongModel.fromDocumentSnap(snap);
  }

  Stream<List<SongModel>> getSongsStream() {
    return _db
        .collection('songs')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((QuerySnapshot querySnapshot) => querySnapshot.docs
            .map((DocumentSnapshot documentSnapshot) =>
                SongModel.fromDocumentSnap(documentSnapshot))
            .toList());
  }

  Stream<List<SongModel>> getLatestSong(String uid) {
    return _db
        .collection('songs')
        .where('uid', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .map((QuerySnapshot querySnapshot) => querySnapshot.docs
            .map((DocumentSnapshot documentSnapshot) =>
                SongModel.fromDocumentSnap(documentSnapshot))
            .toList());
  }

  Future<void> deleteSong(String songId) async {
    try {
      final DocumentReference songRef = _db.collection('songs').doc(songId);
      final DocumentSnapshot songSnapshot = await songRef.get();

      if (songSnapshot.exists) {
        print('Deleting song $songId');
        // delete the song document from the songs collection
        await songRef.delete();

        // delete the song file from Firebase Storage
        final Map<String, dynamic> songData =
            songSnapshot.data() as Map<String, dynamic>;
        final String audioUrl = songData['audio'];
        final String albumCoverUrl = songData['album_cover'];

        final Reference audioRef =
            FirebaseStorage.instance.refFromURL(audioUrl);
        final Reference albumCoverRef =
            FirebaseStorage.instance.refFromURL(albumCoverUrl);

        await audioRef.delete();
        await albumCoverRef.delete();
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<double> get uploadProgressStream =>
      _uploadProgressStreamController.stream;

  @override
  void dispose() {
    super.dispose();
    _uploadProgressStreamController.close();
  }

  Future<void> addToLikedSongs(String songId) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      DocumentReference songRef = userRef.collection('likedSongs').doc(songId);
      DocumentSnapshot songSnap = await songRef.get();
      if (!songSnap.exists) {
        // Add song to liked songs subcollection
        SongModel song = await getSongById(songId);
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
