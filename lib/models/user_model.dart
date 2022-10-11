import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid, username, email, image, age, gender;
  Timestamp created, updated;
  List<String> songs;

  UserModel(this.uid, this.username, this.email, this.age, this.gender,  this.image, this.created, this.updated, this.songs);

  static UserModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return UserModel(
      snap.id,
      json['username'] ?? '',
      json['email'] ?? '',
      json['age'] ?? '',
      json['gender'] ?? '',
      json['image'] ?? '',
      json['created'] ?? Timestamp.now(),
      json['updated'] ?? Timestamp.now(),
      json['songs'] != null
          ? List<String>.from(json['songs'])
          : <String>[],
    );
  }

  Map<String, dynamic> get json => {
        'uid': uid,
        'username': username,
        'email': email,
        'age': age,
        'gender': gender,
        'image': image,
        'created': created,
        'updated': updated,
        'songs' : songs
      };

  static Future<UserModel> fromUid({required String uid}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromDocumentSnap(snap);
  }

  static Stream<UserModel> fromUidStream({required String uid}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(UserModel.fromDocumentSnap);
  }

    static Future<List<UserModel>> getUsers() async {
    List<UserModel> users = [];
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        users.add(UserModel.fromDocumentSnap(doc));
      }
    });

    return users;
  }

  searchUsername(String user) {
    return username.toLowerCase().contains(user.toLowerCase());
  }

}
