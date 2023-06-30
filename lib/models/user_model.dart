import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid,
      username,
      lastName,
      firstName,
      email,
      profileImage,
      age,
      gender,
      headerImage,
      accountType;
  Timestamp created, updated;
  List<String> chatrooms;
  final List<String> followers;
  final List<String> followings;

  UserModel(
      this.uid,
      this.username,
      this.lastName,
      this.firstName,
      this.email,
      this.age,
      this.gender,
      this.profileImage,
      this.headerImage,
      this.created,
      this.updated,
      this.chatrooms,
      this.accountType,
      this.followers,
      this.followings);

  static UserModel fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = {};
    if (snap.data() != null) {
      json = snap.data() as Map<String, dynamic>;
    }
    return UserModel(
      snap.id,
      json['username'] ?? '',
      json['lastName'] ?? '',
      json['firstName'] ?? '',
      json['email'] ?? '',
      json['age'] ?? '',
      json['gender'] ?? '',
      json['profileImage'] ?? '',
      json['headerImage'] ?? '',
      json['created'] ?? Timestamp.now(),
      json['updated'] ?? Timestamp.now(),
      json['chatrooms'] != null
          ? List<String>.from(json['chatrooms'])
          : <String>[],
      json['accountType'] ?? '',
      json['followers'] != null
          ? List<String>.from(json['followers'])
          : <String>[],
      json['followings'] != null
          ? List<String>.from(json['followings'])
          : <String>[],
    );
  }

  Map<String, dynamic> get json => {
        'uid': uid,
        'username': username,
        'lastName': lastName,
        'firstName': firstName,
        'email': email,
        'age': age,
        'gender': gender,
        'profileImage': profileImage,
        'headerImage': headerImage,
        'accountType': accountType,
        'created': created,
        'updated': updated,
        'followers': followers,
        'followings': followings
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

  static Future<UserModel?> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserModel userModel = await UserModel.fromUid(uid: user.uid);
      return userModel;
    }
    return null;
  }

  Future<void> updateProfile(
    String? username,
    String? lastName,
    String? firstName,
  ) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;

    if (lastName != null) data['lastName'] = lastName;
    if (firstName != null) data['firstName'] = firstName;
    await FirebaseFirestore.instance.collection('users').doc(uid).update(data);
  }

  static Future<int> getFollowersLength(String uid) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final followers = userData['followers'] as List<dynamic>?;
      if (followers != null) {
        return followers.length;
      }
    }
    return 0;
  }

  static Future<List<UserModel>> getNonFollowers(String currentUserUid) async {
    List<UserModel> nonFollowers = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    nonFollowers = querySnapshot.docs
        .map((documentSnapshot) => UserModel.fromDocumentSnap(documentSnapshot))
        .where((user) => !user.followers.contains(currentUserUid))
        .toList();

    return nonFollowers;
  }
}
