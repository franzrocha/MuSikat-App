import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArtistDetailsController extends GetxController {
  final selectedArtistFollowsCurrentUser = false.obs;

  void setSelectedArtistFollowsCurrentUser(
      String currentUser, List<String> selectedUserFollowings) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedArtistFollowsCurrentUser.value =
          selectedUserFollowings.contains(currentUser);
    });
  }

  bool get artistIsFollowingUser => selectedArtistFollowsCurrentUser.value;
}
