// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  File? image;
  String? imagepath;

  void selectimage() async {
    FilePickerResult? image = await FilePicker.platform.pickFiles();

    setState(() {
      image = image;
      FileType.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () => selectimage(),
              child: const Text("Select Image"),
            ),
            const SizedBox(
              height: 10,
            ),
            RaisedButton(
              onPressed: () => {},
              child: const Text("Select Song"),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                controller: songname,
                decoration: const InputDecoration(
                  filled: true, //<-- SEE HERE
                  fillColor: Colors.white,
                  hintText: "Enter Song Name",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                controller: artistname,
                decoration: const InputDecoration(
                  filled: true, //<-- SEE HERE
                  fillColor: Colors.white,
                  hintText: "Enter Artist Name",
                ),
              ),
            ),
            RaisedButton(
              onPressed: () => {},
              child: const Text("Upload Song"),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
