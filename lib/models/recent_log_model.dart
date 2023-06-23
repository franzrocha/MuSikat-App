import 'package:cloud_firestore/cloud_firestore.dart';

class RecentLogsModel {
  final String uid;
  final String recentList;
  final String uploadedPhoto;
  final String type;
  final Timestamp timestamp;

  RecentLogsModel({
    required this.uid,
    required this.recentList,
    required this.uploadedPhoto,
    required this.type,
    required this.timestamp,
  });
}

class RecentLengthRecord {
  final String length;

  RecentLengthRecord({required this.length});
}
