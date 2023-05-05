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

  Future<List<SongModel>> getSongsForPlaylist(String playlistId) async {
    DocumentReference playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    DocumentSnapshot playlistSnap = await playlistRef.get();
    PlaylistModel playlist = PlaylistModel.fromDocumentSnap(playlistSnap);

    List<SongModel> songs = [];

    for (String songId in playlist.songs) {
      DocumentReference songRef =
          FirebaseFirestore.instance.collection('songs').doc(songId);
      DocumentSnapshot songSnap = await songRef.get();
      SongModel song = SongModel.fromDocumentSnap(songSnap);
      songs.add(song);
    }

    return songs;
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
}
