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

  Future<List<SongModel>> getEmotionSongs(String emotion) async {
    final List<String> descriptions = [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('descriptions')
        .where('emotion', isEqualTo: emotion)
        .get();

    descriptions
        .addAll(querySnapshot.docs.map((doc) => doc['description'] as String));

    const chunkSize = 5;
    final chunkedDescriptions = <List<String>>[];

    for (var i = 0; i < descriptions.length; i += chunkSize) {
      final end = (i + chunkSize < descriptions.length)
          ? i + chunkSize
          : descriptions.length;
      final chunk = descriptions.sublist(i, end);
      chunkedDescriptions.add(chunk);
    }

    final Set<SongModel> songs = {};

    for (final chunk in chunkedDescriptions) {
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

    final List<SongModel> userSongs =
        songs.where((song) => song.uid == userId).toList();

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

    List<UserModel> users = [];
    final int chunksCount = (userIds.length / 10).ceil();

    for (var i = 0; i < chunksCount; i++) {
      int start = i * 10;
      int end = (i + 1) * 10;
      List<String> chunk =
          userIds.sublist(start, end > userIds.length ? userIds.length : end);

      QuerySnapshot usersSnapshot = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      users.addAll(usersSnapshot.docs
          .map((doc) => UserModel.fromDocumentSnap(doc))
          .toList());
    }

    print(users);

    return users;
  }

  Future<int> getPlaylistAdds(String songId) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('playlists').get();

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

  Future<List<Map<String, dynamic>>> getRanked() async {
    final QuerySnapshot snapshot = await _db.collection('songs').get();
    print('This is here before snapshot');

    final List<SongModel> songs = snapshot.docs
        .map((DocumentSnapshot documentSnapshot) =>
            SongModel.fromDocumentSnap(documentSnapshot))
        .toList();
    print(songs);
    int totalPlayCount = 0;
    int totalLikeCount = 0;
    int totalPlaylistAdds = 0;

    List<Map<String, dynamic>> rankedSongs = [];

    DateTime currentDate = DateTime.now();
    DateTime todayStartDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    DateTime todayEndDate = DateTime(
        currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);

    print(todayStartDate);
    print(todayEndDate);

    // Calculate the total play count, like count, and playlist adds of all the user's songs
    for (SongModel song in songs) {
      totalPlayCount += song.playCount;
      totalLikeCount += song.likeCount;
      totalPlaylistAdds += await getPlaylistAdds(song.songId);
    }

    // Filter songs to include only those played today
    List<SongModel> songsPlayedToday = songs
        .where((song) =>
            song.playCount > 0) // You can add additional conditions if needed
        .toList();

    // Sort the songs based on play count to get the most played songs today
    songsPlayedToday.sort((a, b) => b.playCount.compareTo(a.playCount));

    // Limit the list to the top 10 songs played today
    songsPlayedToday = songsPlayedToday.take(20).toList();

    // Calculate the percentage score for each song and store it in a list of maps
    for (SongModel song in songsPlayedToday) {
      int playlistAdds = await getPlaylistAdds(song.songId);
      double playPercentage = (song.playCount / totalPlayCount) * 100;
      double likePercentage = (song.likeCount / totalLikeCount) * 100;
      double playlistAddsPercentage = (playlistAdds / totalPlaylistAdds) * 100;

      // You can adjust the weights for play count, like count, and playlist adds as per your preference
      double percentageScore = (playPercentage * 0.4) +
          (likePercentage * 0.4) +
          (playlistAddsPercentage * 0.2);
      rankedSongs.add({
        'song': song,
        'percentageScore': percentageScore,
        'playCount': song.playCount,
        'likeCount': song.likeCount,
      });
    }

    // Sort the songs and percentage scores based on the percentage scores (highest first)
    rankedSongs.sort((a, b) => b['playCount'].compareTo(a['playCount']));

    return rankedSongs;
  }

  Future<List<Map<String, dynamic>>> getRankedUsers() async {
    QuerySnapshot songsSnapshot = await _db.collection('songs').get();
    List<SongModel> songs = songsSnapshot.docs
        .map((doc) => SongModel.fromDocumentSnap(doc))
        .toList();

    List<String> userIds = songs.map((song) => song.uid).toSet().toList();

    if (userIds.isEmpty) {
      return []; // Return an empty list if there are no users with songs
    }

    List<Map<String, dynamic>> rankedUsers = [];
    final int chunksCount = (userIds.length / 10).ceil();

    for (var i = 0; i < chunksCount; i++) {
      int start = i * 10;
      int end = (i + 1) * 10;
      List<String> chunk =
          userIds.sublist(start, end > userIds.length ? userIds.length : end);

      QuerySnapshot usersSnapshot = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      List<UserModel> users = usersSnapshot.docs
          .map((doc) => UserModel.fromDocumentSnap(doc))
          .toList();

      // Calculate the total play count, like count, and playlist adds of all the user's songs
      int totalPlayCount = 0;
      int totalLikeCount = 0;
      int totalPlaylistAdds = 0;

      for (SongModel song in songs) {
        if (users.any((user) => user.uid == song.uid)) {
          totalPlayCount += song.playCount;
          totalLikeCount += song.likeCount;
          totalPlaylistAdds += await getPlaylistAdds(song.songId);
        }
      }

      // Calculate the percentage score for each user and store it in the list
      for (UserModel user in users) {
        int userTotalPlayCount = songs
            .where((song) => song.uid == user.uid)
            .map((song) => song.playCount)
            .fold(0, (prev, curr) => prev + curr);

        double playPercentage = (userTotalPlayCount / totalPlayCount) * 100;
        double likePercentage = (userTotalPlayCount / totalLikeCount) * 100;
        double playlistAddsPercentage =
            (userTotalPlayCount / totalPlaylistAdds) * 100;

        // You can adjust the weights for play count, like count, and playlist adds as per your preference
        double percentageScore = (playPercentage * 0.4) +
            (likePercentage * 0.4) +
            (playlistAddsPercentage * 0.2);

        rankedUsers.add({
          'user': user,
          'percentageScore': percentageScore,
          'totalPlayCount': userTotalPlayCount,
          'totalLikeCount': userTotalPlayCount,
        });
      }
    }

    // Sort the users and percentage scores based on the percentage scores (highest first)
    rankedUsers
        .sort((a, b) => b['totalPlayCount'].compareTo(a['totalPlayCount']));

    return rankedUsers;
  }
}
