// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/widgets/toast_msg.dart';

class ImageService {
  static updateProfileImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final storageRef = FirebaseStorage.instance.ref();

        final String? uid = FirebaseAuth.instance.currentUser?.uid;
        final DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final UserModel user = UserModel.fromDocumentSnap(userSnapshot);
        final String username = user.username;

        final profileRef = storageRef.child(
          'users/$username/profileImage/${image.path.split('/').last}',
        );

        print(profileRef.fullPath);
        File file = File(image.path);
        print(image.path);
        TaskSnapshot result = await profileRef.putFile(file);
        print(result);
        String publicUrl = await profileRef.getDownloadURL();
        print(publicUrl);

        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'profileImage': publicUrl});

        ToastMessage.show(context, 'Profile image updated successfully');
      } else {}
    } catch (e) {
      ToastMessage.show(context, 'Upload failed');
    }
  }

  static updateHeaderImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final storageRef = FirebaseStorage.instance.ref();

        final String? uid = FirebaseAuth.instance.currentUser?.uid;
        final DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final UserModel user = UserModel.fromDocumentSnap(userSnapshot);
        final String username = user.username;

        final headerRef = storageRef.child(
          'users/$username/headerImage/${image.path.split('/').last}',
        );
        print(headerRef.fullPath);
        File file = File(image.path);
        print(image.path);
        TaskSnapshot result = await headerRef.putFile(file);
        print(result);
        String publicUrl = await headerRef.getDownloadURL();
        print(publicUrl);
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'headerImage': publicUrl});

        ToastMessage.show(context, 'Header image updated successfully');
      } else {}
    } catch (e) {
      ToastMessage.show(context, 'Upload failed');
    }
  }
}
