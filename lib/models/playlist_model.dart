import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String playlistId, title, uid;
  final DateTime createdAt;
  List<String> songs;
  String? description;
  final String playlistImg;
  bool isOfficial;
  String genre;

  PlaylistModel({
    required this.playlistId,
    required this.title,
    required this.createdAt,
    required this.songs,
    required this.uid,
    this.description,
    required this.playlistImg,
    required this.isOfficial,
    required this.genre,
  });

  static PlaylistModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;

    return PlaylistModel(
      playlistId: snap.id,
      title: json['title'] ?? '',
      description: json['description'],
      playlistImg: json['playlistImg'],
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      songs: (json['songs'] as List<dynamic>?)?.cast<String>() ?? [],
      uid: json['uid'] ?? '',
      isOfficial: json['isOfficial'] ?? false,
      genre: json['genre'] ?? '',
    );
  }

  Map<String, dynamic> get json => {
        'playlistId': playlistId,
        'title': title,
        'description': description,
        'playlistImg': playlistImg,
        'createdAt': createdAt,
        'songs': songs,
        'uid': uid,
        'isOfficial': isOfficial,
        'genre': genre,
      };

      

}


//   static Future<List<PlaylistModel>> getPlaylists() async {
//     List<PlaylistModel> playlists = [];
//     await FirebaseFirestore.instance
//         .collection('playlists')
//         .get()
//         .then((QuerySnapshot querySnapshot) {
//       for (var doc in querySnapshot.docs) {
//         playlists.add(PlaylistModel.fromDocumentSnap(doc));
//       }
//     });

//     return playlists;
//   }

//  searchPlaylist(String query) {
//     String lowerCaseQuery = query.toLowerCase();
//     String lowerCaseTitle = title.toLowerCase();
//     return lowerCaseTitle.contains(lowerCaseQuery);
//   }

