import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:musikat_app/constants.dart';

class UploadScreen extends StatefulWidget {
  static const String route = 'artists-screen';
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  TextEditingController songname = TextEditingController();
  TextEditingController artistname = TextEditingController();

  String? imagepath;
  File? file;

  String url = "";
  // ignore: prefer_typing_uninitialized_variables
  var name;

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
      appBar: appbar(context),
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => getsong(),
              child: const Text("Upload Song"),
            ),
            const SizedBox(
              height: 10,
            ),

            // // Padding(
            // //   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            // //   child: TextField(
            // //     controller: songname,
            // //     decoration: const InputDecoration(
            // //       filled: true, //<-- SEE HERE
            // //       fillColor: Colors.white,
            // //       hintText: "Enter Song Name",
            // //     ),
            // //   ),
            // // ),
            // // Padding(
            // //   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            // //   child: TextField(
            // //     controller: artistname,
            // //     decoration: const InputDecoration(
            // //       filled: true, //<-- SEE HERE
            // //       fillColor: Colors.white,
            // //       hintText: "Enter Artist Name",
            // //     ),
            // //   ),
            // // ),
            // // RaisedButton(
            // //   onPressed: () => {},
            // //   child: const Text("Upload Song"),
            // // ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text("Upload a file",
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const FaIcon(
          FontAwesomeIcons.angleLeft,
          size: 20,
        ),
      ),
    );
  }
}
