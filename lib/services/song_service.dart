// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:musikat_app/models/user_model.dart';

class SongService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uploadProgressStreamController = StreamController<double>.broadcast();

  Stream<double> get uploadProgressStream =>
      _uploadProgressStreamController.stream;

  UploadTask? _uploadTask;

  Future<String> uploadSong(
      String title,
      String artist,
      String filePath,
      String coverPath,
      List<String> writers,
      List<String> producers,
      String genre,
      String uid,
      List<String> languages,
      List<String> description,
      {String? albumCover}) async {
    try {
      // Retrieves the user's username from Firestore using the user's uid as a reference
      final DocumentSnapshot userSnapshot =
          await _db.collection('users').doc(uid).get();
      final UserModel user = UserModel.fromDocumentSnap(userSnapshot);
      final String username = user.username;

      final String fileName = filePath.split('/').last;
      final String coverFileName = coverPath.split('/').last;

      // Creates a reference to the audio and album cover files in Firebase Storage
      final Reference audioRef =
          FirebaseStorage.instance.ref('users/$username/audios/$fileName');
      final Reference coverRef = FirebaseStorage.instance
          .ref('users/$username/albumCovers/$coverFileName');

      // Upload the audio and album cover files to Firebase Storage
      _uploadTask = audioRef.putFile(File(filePath));

      _uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        _uploadProgressStreamController.sink.add(progress);
      });

      final TaskSnapshot taskSnapshot = await _uploadTask!;
      final UploadTask coverUploadTask = coverRef.putFile(File(coverPath));
      final TaskSnapshot coverTaskSnapshot = await coverUploadTask;
      final String downloadUrl = await audioRef.getDownloadURL();
      final String coverDownloadUrl = await coverRef.getDownloadURL();

      final Map<String, dynamic> metadata = {
        'song_id': '',
        'title': title,
        'artist': artist,
        'file_name': fileName,
        'created_at': FieldValue.serverTimestamp(),
        'audio': downloadUrl,
        'album_cover': coverDownloadUrl,
        'writers': writers,
        'producers': producers,
        'genre': genre,
        'uid': uid,
        'languages': languages,
        'description': description,
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

  void cancelUpload() {
    if (_uploadTask != null) {
      _uploadTask!.cancel();
      _uploadTask = null;
    }
  }

Future<String> updateSong(
  String songId,
  String title,
  String? albumCover,
  List<String> writers,
  List<String> producers,
  String genre,
  List<String> languages,
  List<String> description,
) async {
  try {
    final DocumentReference docRef = _db.collection('songs').doc(songId);
    final DocumentSnapshot songSnapshot = await docRef.get();
    final String currentCoverUrl = songSnapshot.get('album_cover');

    String newCoverDownloadUrl = currentCoverUrl; 

    if (albumCover != null) {
      final Reference currentCoverRef = FirebaseStorage.instance.refFromURL(currentCoverUrl);

      final String fileName = albumCover.split('/').last;
      final Reference newCoverRef = FirebaseStorage.instance.ref('albumCovers/$fileName');
      final UploadTask coverUploadTask = newCoverRef.putFile(File(albumCover));
      final TaskSnapshot coverTaskSnapshot = await coverUploadTask;
      newCoverDownloadUrl = await newCoverRef.getDownloadURL();
    }

    final Map<String, dynamic> updatedData = {
      'title': title,
      'album_cover': newCoverDownloadUrl,
      'writers': writers,
      'producers': producers,
      'genre': genre,
      'languages': languages,
      'description': description,
    };
    await docRef.update(updatedData);

    return songId;
  } catch (e) {
    print(e.toString());
    return '';
  }
}

}
