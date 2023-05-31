import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/utils/exports.dart';

class FollowController with ChangeNotifier {
  // Method to follow a user
  void followUser(String userIdToFollow) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    // Update the current user's followings list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'followings': FieldValue.arrayUnion([userIdToFollow])
    });

    // Update the target user's followers list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userIdToFollow)
        .update({
      'followers': FieldValue.arrayUnion([currentUserId])
    });
  }

  // Method to unfollow a user
  void unfollowUser(String userIdToUnfollow) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    // Update the current user's followings list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'followings': FieldValue.arrayRemove([userIdToUnfollow])
    });

    // Update the target user's followers list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userIdToUnfollow)
        .update({
      'followers': FieldValue.arrayRemove([currentUserId])
    });
  }

  // Method to get a user's followers
  Future<List<String>> getUserFollowers(String selectedUserUID) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserUID)
        .get();

    final followersList =
        (userSnapshot.data()?['followers'] as List<dynamic>?) ?? [];

    return followersList.cast<String>();
  }

  // Method to get a user's followings list
  Future<List<String>> getUserFollowing(String selectedUserUID) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserUID)
        .get();

    final followingList =
        (userSnapshot.data()?['followings'] as List<dynamic>?) ?? [];
    return followingList.cast<String>();
  }

  Future<bool> isUserFollowingCurrentUser(String userIdToCheck) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    // Get the current user's followings list
    final followingListSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    final followingList =
        (followingListSnapshot.data()?['followings'] as List<dynamic>?) ?? [];

    // Check if the given user is in the current user's followings list
    return followingList.contains(userIdToCheck);
  }
}
