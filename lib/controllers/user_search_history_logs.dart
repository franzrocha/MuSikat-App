import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/recent_log_model.dart';
import 'package:musikat_app/utils/exports.dart';

class RecentHistoryUserSearchLogs with ChangeNotifier {
  //collection key to get the exactly data in firestore firebase database
  CollectionReference recentLogs =
      FirebaseFirestore.instance.collection('userSearchHistoryLogs');

  //timestamp
  DateTime currentDate = DateTime.now();

  //adding new record in firestore database

// Future<List<RecentLogsModel>> it means you use asynchronous method for getting data its that flutter provide
  Future<void> addSearchHistoryLogs(
      String id, String recent, String photo, String type) async {
    //uid for current user
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    //delete same recent id to prevent duplicated record on firestore firebase database
    await recentLogs.where("recent_id", isEqualTo: id).get().then((value) {
      for (var element in value.docs) {
        recentLogs.doc(element.id).delete();
      }
    });

    //push a new collection data in firestore firebase database
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

  //this code is not included sorting data base on the date descending order

  // Future<List<RecentLogsModel>> getHistoryLogs()  async {
  //   String? uid = FirebaseAuth.instance.currentUser?.uid;
  //   print('uid list');
  //   print(uid);
  //   List<RecentLogsModel> getRecentLogs = [];
  //   final querySnapshot =
  //   await recentLogs.where('uid', isEqualTo: uid).get();
  //   for (var i = querySnapshot.docs.length - 1; i >= 0; i--) {
  //     final doc = querySnapshot.docs[i];
  //     final recentList = doc['recent'];
  //     final uid = doc['recent_id'];
  //     final uploadedPhoto = doc['uploaded_photo'];
  //     final type = doc['type'];
  //     getRecentLogs.add(RecentLogsModel(uid: uid, recentList: recentList, uploadedPhoto: uploadedPhoto,type:type));
  //
  //   }
  //
  //
  //   return getRecentLogs;
  // }

  //this code for getting records for the list of recent details and converted the data to list of array before show on the page

  // Future<List<RecentLogsModel>> it means you use asynchoronous method for getting data its that flutter provide
  Future<List<RecentLogsModel>> getHistoryLogs() async {
    //uid for current user
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    //creating new array list for getting the records
    List<RecentLogsModel> getRecentLogs = [];

    //query to the list in firebase firestore
    final querySnapshot = await recentLogs.where('uid', isEqualTo: uid).get();

    //loop the value listed in the firebase firestore
    for (var i = querySnapshot.docs.length - 1; i >= 0; i--) {
      final doc = querySnapshot.docs[i];
      final recentList = doc['recent'];
      final uid = doc['recent_id'];
      final uploadedPhoto = doc['uploaded_photo'];
      final type = doc['type'];
      final timestamp = doc['timestamp'];

      //push a new value to created list
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

    // Sort the getRecentLogs list in descending order based on timestamp
    getRecentLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    //dispatch the returh call for recent logs
    return getRecentLogs;
  }

  //this code indicated to delete user when button close clicked

  Future<void> deleteHistoryLogs(String userId) async {
    await recentLogs.where("recent_id", isEqualTo: userId).get().then((value) {
      for (var element in value.docs) {
        recentLogs.doc(element.id).delete();
      }
    });
  }

  //this code use for counter state to handle condition for showing the page and get the length value and set to the counter state
  Future<int> getLengthRecord() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    //query to the list in firebase firestore
    final querySnapshot = await recentLogs.where('uid', isEqualTo: uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.length;
    }

    return 0;
  }

//this code serve as controller for making a recent log history, its like a methods how the user interface controlled
}
