import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeago;

class FirebaseService with ChangeNotifier {
  CollectionReference<Object?> collectionReferenceDb(String db) {
    CollectionReference dbCollection =
        FirebaseFirestore.instance.collection(db);

    return dbCollection;
  }

  DateTime getCurrentTimeStamp() {
    DateTime currentDate = DateTime.now();

    return currentDate;
  }

  String? getCurrentUserId() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return uid;
  }

  void deleteAllCollection(db, field, userId) {
    FirebaseFirestore.instance
        .collection(db)
        .where(field, isEqualTo: userId)
        .snapshots()
        .forEach((querySnapshot) {
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        docSnapshot.reference.delete();
      }
    });
  }
}

class UserNotificationController with ChangeNotifier {
  static final firebaseService = FirebaseService();
  static final dbCollection =
      firebaseService.collectionReferenceDb('userNotification');

  final currentDate = firebaseService.getCurrentTimeStamp();
  final uid = firebaseService.getCurrentUserId();

  Future<void> addUserNotification(String following, int notify) async {
    return dbCollection
        .add({
          'follower': uid,
          'following': following,
          'notify': notify,
          'timestamp': currentDate
        })
        .then((value) => print("User notified"))
        .catchError(
            (error) => print("Ohh sorry there something wrong with it."));
  }

  void deleteNotification(String followerId) async {
    return dbCollection
        .where('follower', isEqualTo: uid)
        .where("following", isEqualTo: followerId)
        .get()
        .then((value) {
      for (var element in value.docs) {
        dbCollection.doc(element.id).delete();

        print('deleted');
      }
    });
  }

  void updateNotificationState(String followerId, String followingId) async {
    final QuerySnapshot querySnapshot = await dbCollection
        .where('follower', isEqualTo: followerId)
        .where('following', isEqualTo: followingId)
        .get();

    for (var doc in querySnapshot.docs) {
      final docRef = dbCollection.doc(doc.id);
      docRef
          .update({
            'notify': 0,
          })
          .then((value) => print('Document successfully updated!'))
          .catchError((error) => print('Error updating document: $error'));
    }
  }

  Stream<QuerySnapshot<Object?>> streamUserNotification(String currentUserId) {
    return dbCollection
        .where('notify', isEqualTo: 1)
        .where('following', isEqualTo: currentUserId)
        .snapshots();
  }

  String getTimeAgo(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }
}
