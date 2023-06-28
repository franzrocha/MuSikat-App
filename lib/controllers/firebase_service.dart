import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/exports.dart';

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
}
