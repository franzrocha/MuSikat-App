// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:musikat_app/models/song_model.dart';

class SongService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uploadProgressStreamController = StreamController<double>.broadcast();

  Stream<double> get uploadProgressStream =>
      _uploadProgressStreamController.stream;

  Future<String> uploadSong(String title, String filePath, String coverPath,
      List<String> writers, List<String> producers, String genre,
      {String? albumCover}) async {
    try {
      final String fileName = filePath.split('/').last;
      final String coverFileName = coverPath.split('/').last;
      final Reference ref =
          FirebaseStorage.instance.ref().child('audios/$fileName');
      final Reference coverRef =
          FirebaseStorage.instance.ref().child('albumCovers/$coverFileName');
      final UploadTask uploadTask = ref.putFile(File(filePath));
      final UploadTask coverUploadTask = coverRef.putFile(File(coverPath));

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        _uploadProgressStreamController.sink.add(progress);
      });

      final TaskSnapshot taskSnapshot = await uploadTask;
      final TaskSnapshot coverTaskSnapshot = await coverUploadTask;
      final String downloadUrl = await ref.getDownloadURL();
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

  Future<List<SongModel>> getSongs() async {
    final QuerySnapshot snapshot = await _db.collection('songs').get();

    return snapshot.docs.map((doc) => SongModel.fromDocumentSnap(doc)).toList();
  }

  Future<SongModel> getSongById(String songId) async {
    final DocumentSnapshot snap =
        await _db.collection('songs').doc(songId).get();
    return SongModel.fromDocumentSnap(snap);
  }

  void cancelUpload() {
    _uploadProgressStreamController.close();
  }
}
