import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

class PlaylistController with ChangeNotifier {
  Stream<List<PlaylistModel>> getPlaylistStream() {
    CollectionReference<Map<String, dynamic>> playlistsRef =
        FirebaseFirestore.instance.collection('playlists');

    return playlistsRef.orderBy('createdAt').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return PlaylistModel.fromDocumentSnap(doc);
      }).toList();
    });
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    DocumentReference playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    DocumentSnapshot playlistSnap = await playlistRef.get();
    PlaylistModel playlist = PlaylistModel.fromDocumentSnap(playlistSnap);

    playlist.songs.add(songId);

    await playlistRef.update(playlist.json);
  }

  Stream<List<SongModel>> getSongsForPlaylist(String playlistId) {
    final playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    return playlistRef.snapshots().asyncMap((playlistSnap) async {
      final playlist = PlaylistModel.fromDocumentSnap(playlistSnap);

      final songs = <SongModel>[];
      for (final songId in playlist.songs) {
        final songRef =
            FirebaseFirestore.instance.collection('songs').doc(songId);
        final songSnap = await songRef.get();
        final song = SongModel.fromDocumentSnap(songSnap);
        songs.add(song);
      }

      return songs;
    });
  }

  Future<UserModel> getUserForPlaylist(String playlistId) async {
    DocumentReference playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    DocumentSnapshot playlistSnap = await playlistRef.get();
    PlaylistModel playlist = PlaylistModel.fromDocumentSnap(playlistSnap);

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(playlist.uid);
    DocumentSnapshot userSnap = await userRef.get();
    UserModel user = UserModel.fromDocumentSnap(userSnap);

    return user;
  }

  Future<void> deletePlaylist(String playlistId) async {
    await FirebaseFirestore.instance
        .collection('playlists')
        .doc(playlistId)
        .delete();
  }

  Future<int> getSongCount(String playlistId) async {
    final snap = await FirebaseFirestore.instance
        .collection('playlists')
        .doc(playlistId)
        .get();
    final data = snap.data();
    if (data != null && data['songs'] != null) {
      return List<String>.from(data['songs']).length;
    } else {
      return 0;
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    DocumentReference playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    DocumentSnapshot playlistSnap = await playlistRef.get();
    PlaylistModel playlist = PlaylistModel.fromDocumentSnap(playlistSnap);

    playlist.songs.remove(songId);

    await playlistRef.update(playlist.json);
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

  Future<PlaylistModel> getPlaylistById(String playlistId) async {
    final DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('playlists')
        .doc(playlistId)
        .get();
    return PlaylistModel.fromDocumentSnap(snap);
  }

  Future<List<String>> getUniqueGenres() async {
    List<String> uniqueGenres = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('playlists')
        .where('isOfficial', isEqualTo: true)
        .get();

    for (var documentSnapshot in querySnapshot.docs) {
      PlaylistModel playlist = PlaylistModel.fromDocumentSnap(documentSnapshot);
      if (!uniqueGenres.contains(playlist.genre)) {
        uniqueGenres.add(playlist.genre);
      }
    }

    return uniqueGenres;
  }
}
