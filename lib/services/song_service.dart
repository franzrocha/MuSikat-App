// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';

class SongService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uploadProgressStreamController = StreamController<double>.broadcast();

  Stream<double> get uploadProgressStream =>
      _uploadProgressStreamController.stream;

  Future<String> uploadSong(String title, String filePath, String coverPath,
      List<String> writers, List<String> producers, String genre, String uid,
      {String? albumCover}) async {
    try {
      // Retrieve the user's username from Firestore using the user's uid as a reference
      final DocumentSnapshot userSnapshot =
          await _db.collection('users').doc(uid).get();
      final UserModel user = UserModel.fromDocumentSnap(userSnapshot);
      final String username = user.username;

      final String fileName = filePath.split('/').last;
      final String coverFileName = coverPath.split('/').last;

      // Create a reference to the audio and album cover files in Firebase Storage
      final Reference audioRef =
          FirebaseStorage.instance.ref('users/$username/audios/$fileName');
      final Reference coverRef = FirebaseStorage.instance
          .ref('users/$username/albumCovers/$coverFileName');

      // Upload the audio and album cover files to Firebase Storage
      final UploadTask uploadTask = audioRef.putFile(File(filePath));
      final UploadTask coverUploadTask = coverRef.putFile(File(coverPath));

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        _uploadProgressStreamController.sink.add(progress);
      });

      final TaskSnapshot taskSnapshot = await uploadTask;
      final TaskSnapshot coverTaskSnapshot = await coverUploadTask;
      final String downloadUrl = await audioRef.getDownloadURL();
      final String coverDownloadUrl = await coverRef.getDownloadURL();

      final Map<String, dynamic> metadata = {
        'song_id': '',
        'title': title,
        'file_name': fileName,
        'created_at': FieldValue.serverTimestamp(),
        'audio': downloadUrl,
        'album_cover': coverDownloadUrl,
        'writers': writers,
        'producers': producers,
        'genre': genre,
        'uid': uid,
      };

      final DocumentReference docRef = _db.collection('songs').doc();
      await docRef.set(metadata);
      await docRef.update({'song_id': docRef.id});

      return docRef.id;
    } catch (e) {
      print(e.toString());
      return '';
    } finally {
      _uploadProgressStreamController.close();
    }
  }

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

  void cancelUpload() {
    _uploadProgressStreamController.close();
  }

  

}
