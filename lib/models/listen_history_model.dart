import 'package:cloud_firestore/cloud_firestore.dart';

class UserPlayHistory {
  final String userId;
  final String songId;
  final DateTime playedAt;

  UserPlayHistory({
    required this.userId,
    required this.songId,
    required this.playedAt,
  });

  static Future<List<UserPlayHistory>> getPlayHistoryForUser(
      {required String userId}) async {
    List<UserPlayHistory> playHistory = [];
    await FirebaseFirestore.instance
        .collection('user_play_history')
        .where('userId', isEqualTo: userId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        playHistory.add(UserPlayHistory.fromDocumentSnap(doc));
      }
    });

    return playHistory;
  }

  static Future<void> addPlayHistory({required UserPlayHistory playHistory}) {
    return FirebaseFirestore.instance
        .collection('user_play_history')
        .add(playHistory.json);
  }

  static UserPlayHistory fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;

    return UserPlayHistory(
      userId: json['userId'] ?? '',
      songId: json['songId'] ?? '',
      playedAt: json['playedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> get json => {
        'userId': userId,
        'songId': songId,
        'playedAt': playedAt,
      };
}
