import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:musikat_app/utils/exports.dart';

class FollowController extends GetxController {
  final selectedArtistFollowsCurrentUser = false.obs;
  void followUser(String userIdToFollow) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'followings': FieldValue.arrayUnion([userIdToFollow])
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userIdToFollow)
        .update({
      'followers': FieldValue.arrayUnion([currentUserId])
    });
  }

  void unfollowUser(String userIdToUnfollow) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'followings': FieldValue.arrayRemove([userIdToUnfollow])
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userIdToUnfollow)
        .update({
      'followers': FieldValue.arrayRemove([currentUserId])
    });
  }

  Future<List<String>> getUserFollowers(String selectedUserUID) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserUID)
        .get();

    final followersList =
        (userSnapshot.data()?['followers'] as List<dynamic>?) ?? [];

    return followersList.cast<String>();
  }

  Future<List<String>> getUserFollowing(String selectedUserUID) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserUID)
        .get();

    final followingList =
        (userSnapshot.data()?['followings'] as List<dynamic>?) ?? [];

    return followingList.cast<String>();
  }

  void setSelectedArtistFollowsCurrentUser(
      String currentUser, List<String> selectedUserFollowings) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedArtistFollowsCurrentUser.value =
          selectedUserFollowings.contains(currentUser);
    });
  }

  bool get artistIsFollowingUser => selectedArtistFollowsCurrentUser.value;
}
