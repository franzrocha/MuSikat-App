// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musikat_app/constants.dart';

class ArtistsScreen extends StatefulWidget {
  static const String route = 'artists-screen';
  const ArtistsScreen({Key? key}) : super(key: key);

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  TextEditingController songname = TextEditingController();
  TextEditingController artistname = TextEditingController();

  // File? song;
  String? imagepath;
  File? file;

  String url = "";
  var name;
  // void selectsong() async {
  //   FilePickerResult? song = await FilePicker.platform.pickFiles(
  //     allowedExtensions: ['mp3'],
  //   );
  // }

  getsong() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    if (result != null) {
      File c = File(result.files.single.path.toString());
      setState(() {
        file = c;
        name = result.names.toString();
      });
      uploadFile();
    }
  }

  uploadFile() async {
    try {
      var songfile =
          FirebaseStorage.instance.ref().child("Songs").child("/$name");
      UploadTask task = songfile.putFile(file!);
      TaskSnapshot snapshot = await task;
      url = await snapshot.ref.getDownloadURL();

      print(url);
      if (file != null) {
        Fluttertoast.showToast(
          msg: "Done Uploaded",
          textColor: Colors.red,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong",
          textColor: Colors.red,
        );
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: Column(
          children: <Widget>[
            // RaisedButton(
            //   onPressed: () => selectimage(),
            //   child: const Text("Select Image"),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            RaisedButton(
              onPressed: () => getsong(),
              child: const Text("Upload Song"),
            ),
            const SizedBox(
              height: 10,
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            //   child: TextField(
            //     controller: songname,
            //     decoration: const InputDecoration(
            //       filled: true, //<-- SEE HERE
            //       fillColor: Colors.white,
            //       hintText: "Enter Song Name",
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            //   child: TextField(
            //     controller: artistname,
            //     decoration: const InputDecoration(
            //       filled: true, //<-- SEE HERE
            //       fillColor: Colors.white,
            //       hintText: "Enter Artist Name",
            //     ),
            //   ),
            // ),
            // RaisedButton(
            //   onPressed: () => {},
            //   child: const Text("Upload Song"),
            // ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
