class RecommendedArtist {
  final String uid;
  final List<String> usersId;

  RecommendedArtist({required this.uid, required this.usersId});

  factory RecommendedArtist.fromJson(Map<String, dynamic> json) {
    return RecommendedArtist(
      uid: json['uid'] as String,
      usersId:
          (json['usersId'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'usersId': usersId,
    };
  }
}
