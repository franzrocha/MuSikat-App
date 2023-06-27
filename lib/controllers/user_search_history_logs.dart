import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/recent_log_model.dart';
import 'package:musikat_app/utils/exports.dart';

class RecentHistoryUserSearchLogs with ChangeNotifier {
  CollectionReference recentLogs =
      FirebaseFirestore.instance.collection('searchHistory');

  DateTime currentDate = DateTime.now();

  Future<void> addSearchHistoryLogs(
      String id, String recent, String photo, String type) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    await recentLogs.where("recent_id", isEqualTo: id).get().then((value) {
      for (var element in value.docs) {
        recentLogs.doc(element.id).delete();
      }
    });

    return recentLogs
        .add({
          'uid': uid,
          'recent_id': id,
          'uploaded_photo': photo,
          'recent': recent,
          'type': type,
          'timestamp': currentDate
        })
        .then((value) => print("Recent Logs added"))
        .catchError((error) => print("Recent log error."));
  }

  Future<List<RecentLogsModel>> getHistoryLogs() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    List<RecentLogsModel> getRecentLogs = [];

    final querySnapshot = await recentLogs.where('uid', isEqualTo: uid).get();

    for (var i = querySnapshot.docs.length - 1; i >= 0; i--) {
      final doc = querySnapshot.docs[i];
      final recentList = doc['recent'];
      final uid = doc['recent_id'];
      final uploadedPhoto = doc['uploaded_photo'];
      final type = doc['type'];
      final timestamp = doc['timestamp'];

      getRecentLogs.add(
        RecentLogsModel(
          uid: uid,
          recentList: recentList,
          uploadedPhoto: uploadedPhoto,
          type: type,
          timestamp: timestamp,
        ),
      );
    }

    getRecentLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return getRecentLogs;
  }

  Future<void> deleteHistoryLogs(String userId) async {
    await recentLogs.where("recent_id", isEqualTo: userId).get().then((value) {
      for (var element in value.docs) {
        recentLogs.doc(element.id).delete();
      }
    });
  }

  Future<int> getLengthRecord() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    final querySnapshot = await recentLogs.where('uid', isEqualTo: uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.length;
    }

    return 0;
  }
}
