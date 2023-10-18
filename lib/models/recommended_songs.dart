class RecommendedSongsModel {
  final String uid;
  final List<String> songId;

  RecommendedSongsModel({required this.uid, required this.songId});

  factory RecommendedSongsModel.fromJson(Map<String, dynamic> json) {
    return RecommendedSongsModel(
      uid: json['uid'] as String,
      songId:
          (json['songId'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'songId': songId,
    };
  }
}
