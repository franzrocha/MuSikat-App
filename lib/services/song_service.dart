// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:musikat_app/models/song_model.dart';
import 'dart:io';

class SongService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> uploadSong(String title, String filePath) async {
    try {
      final String fileName = filePath.split('/').last;
      final Reference ref =
          FirebaseStorage.instance.ref().child('audios/$fileName');
      final UploadTask uploadTask = ref.putFile(File(filePath));

      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      final String downloadUrl = await ref.getDownloadURL();

      final Map<String, dynamic> metadata = {
        'song_id': '',
        'title': title,
        'file_name': fileName,
        'created_at': FieldValue.serverTimestamp(),
        'audio_location': downloadUrl,
      };

      final DocumentReference docRef = _db.collection('songs').doc();
      await docRef.set(metadata);
      await docRef.update({'song_id': docRef.id});

      return docRef.id;
    } catch (e) {
      print(e.toString());
      return '';
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
}
