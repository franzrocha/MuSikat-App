import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/utils/exports.dart';

class PlaylistController with ChangeNotifier {
  Stream<List<PlaylistModel>> getPlaylistStream() {

    CollectionReference<Map<String, dynamic>> playlistsRef =
        FirebaseFirestore.instance.collection('playlists');

    return playlistsRef.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return PlaylistModel.fromDocumentSnap(doc);
      }).toList();
    });
  }
}
