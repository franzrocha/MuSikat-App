import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

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
        await songRef.delete();
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<SongModel>> getDescriptionSongs(String description) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('songs')
        .where('description', arrayContains: description)
        .get();

    final songs = querySnapshot.docs
        .map((doc) => SongModel.fromDocumentSnap(doc))
        .toList();

    return songs;
  }

  Future<List<SongModel>> getEmotionSongs(String description) async {
    List<String> emotion = [];

    if (description == 'happy') {
      emotion.addAll(happy);
    } else if (description == 'sad') {
      emotion.addAll(sad);
    } else if (description == 'angry') {
      emotion.addAll(angry);
    } else {
      emotion.addAll(normal);
    }

    const chunkSize = 5;
    final chunkedEmotions = <List<String>>[];

    for (var i = 0; i < emotion.length; i += chunkSize) {
      final end =
          (i + chunkSize < emotion.length) ? i + chunkSize : emotion.length;
      final chunk = emotion.sublist(i, end);
      chunkedEmotions.add(chunk);
    }

    final Set<SongModel> songs = {};

    for (final chunk in chunkedEmotions) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('songs')
          .where('description', arrayContainsAny: chunk)
          .get();

      final chunkSongs = querySnapshot.docs
          .map((doc) => SongModel.fromDocumentSnap(doc))
          .toSet();

      songs.addAll(chunkSongs);
    }

    return songs.toList();
  }

  Future<List<SongModel>> getGenreSongs(String genre) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('songs')
        .where('genre', isEqualTo: genre)
        .get();

    final songs = querySnapshot.docs
        .map((doc) => SongModel.fromDocumentSnap(doc))
        .where((song) => song.languages.isNotEmpty)
        .toList();

    return songs;
  }

  Future<List<SongModel>> getAllLanguageSongs(String languages) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('songs')
        .where('languages', arrayContains: languages)
        .get();

    final songs = querySnapshot.docs
        .map((doc) => SongModel.fromDocumentSnap(doc))
        .where((song) => song.languages.isNotEmpty)
        .toList();

    return songs;
  }

  Future<int> getUserSongCount() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final CollectionReference songsCollection =
        FirebaseFirestore.instance.collection('songs');
    QuerySnapshot snapshot =
        await songsCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs.length;
  }

Future<List<SongModel>> getRankedSongs(String userId) async {
  final QuerySnapshot snapshot = await _db.collection('songs').get();

  final List<SongModel> songs = snapshot.docs
      .map((DocumentSnapshot documentSnapshot) =>
          SongModel.fromDocumentSnap(documentSnapshot))
      .toList();

  songs.sort((a, b) =>
      (b.playCount + b.likeCount).compareTo(a.playCount + a.likeCount));

  final List<SongModel> userSongs = songs
      .where((song) => song.uid == userId)
      .toList();

  return userSongs;
}

  Future<int> getLikeSongCount() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final CollectionReference songsCollection =
        FirebaseFirestore.instance.collection('likedSongs');
    QuerySnapshot snapshot =
        await songsCollection.where('songId', isEqualTo: uid).get();
    return snapshot.docs.length;
  }

  Future<void> updateSongPlayCount(String songId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot songSnapshot =
        await FirebaseFirestore.instance.collection('songs').doc(songId).get();

    if (songSnapshot.exists) {
      Map<String, dynamic>? songData =
          songSnapshot.data() as Map<String, dynamic>?;
      String owner = songData!['uid'];

      if (owner != userId) {
        await FirebaseFirestore.instance
            .collection('songs')
            .doc(songId)
            .update({'playCount': FieldValue.increment(1)});
      }
    }
  }

  Stream<double> get uploadProgressStream =>
      _uploadProgressStreamController.stream;

  @override
  void dispose() {
    super.dispose();
    _uploadProgressStreamController.close();
  }

  Future<int> getOverallPlays(String currentUserUid) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('songs')
        .where('uid', isEqualTo: currentUserUid)
        .get();

    int totalPlayCount = 0;

    for (final doc in querySnapshot.docs) {
      final SongModel song = SongModel.fromDocumentSnap(doc);
      totalPlayCount += song.playCount;
    }

    return totalPlayCount;
  }

  
  Future<int> getOverallLikes(String currentUserUid) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('songs')
        .where('uid', isEqualTo: currentUserUid)
        .get();

    int totalLikeCount = 0;

    for (final doc in querySnapshot.docs) {
      final SongModel song = SongModel.fromDocumentSnap(doc);
      totalLikeCount += song.likeCount;
    }

    return totalLikeCount;
  }

  Future<List<UserModel>?> getUsersWithSongs() async {
    QuerySnapshot songsSnapshot = await _db.collection('songs').get();

    List<SongModel> songs = songsSnapshot.docs
        .map((doc) => SongModel.fromDocumentSnap(doc))
        .toList();

    List<String> userIds = songs.map((song) => song.uid).toSet().toList();

    if (userIds.isEmpty) {
      return null;
    }

    QuerySnapshot usersSnapshot = await _db
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    return usersSnapshot.docs
        .map((doc) => UserModel.fromDocumentSnap(doc))
        .toList();
  }

  Future<int> getOwnedSongCount(String userId, String songId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('playlists')
          // .where('uid', isEqualTo: userId)
          .get();

      int count = 0;

      for (DocumentSnapshot doc in snapshot.docs) {
        PlaylistModel playlist = PlaylistModel.fromDocumentSnap(doc);

        if (playlist.songs.contains(songId)) {
          count++;
        }
      }

      return count;
    } catch (e) {
      print('Error retrieving owned song count: $e');
      return 0;
    }
  }

  //calculate the popularity score
}
