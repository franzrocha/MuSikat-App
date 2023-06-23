import 'package:cloud_firestore/cloud_firestore.dart';

//this class blueprint serves as model for the user recent history log to make the type tha passing is typesafe
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

//this also use for model for gettinh the length value for firebase store database that's located in user search log history controller
class RecentLengthRecord {
  final String length;

  RecentLengthRecord({required this.length});
}
