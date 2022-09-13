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

  // getsong() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['mp3', 'wav'],
  //   );

  //   if (result != null) {
  //     File c = File(result.files.single.path.toString());
  //     setState(() {
  //       file = c;
  //       name = result.names.toString();
  //     });
  //     uploadFile();
  //   }
  // }

  // uploadFile() async {
  //   try {
  //     var songfile =
  //         FirebaseStorage.instance.ref().child("Songs").child("/$name");
  //     UploadTask task = songfile.putFile(file!);
  //     TaskSnapshot snapshot = await task;
  //     url = await snapshot.ref.getDownloadURL();

  //     print(url);
  //     if (file != null) {
  //       Fluttertoast.showToast(
  //         msg: "Done Uploaded",
  //         textColor: Colors.red,
  //       );
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: "Something went wrong",
  //         textColor: Colors.red,
  //       );
  //     }
  //   } on Exception catch (e) {
  //     Fluttertoast.showToast(
  //       msg: e.toString(),
  //       textColor: Colors.red,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      backgroundColor: musikatBackgroundColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Ink(
                width: 198,
                height: 186,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    width: 1.0,
                  ),
                ),
                child: InkWell(
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.camera_alt,
                      size: 50.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '   Choose an image \n for your album cover',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            titleForm(context),
            const SizedBox(
              height: 15,
            ),
            writersForm(context),
            const SizedBox(
              height: 15,
            ),
            producersForm(context),
            const SizedBox(
              height: 15,
            ),
            languangeForm(context),
            const SizedBox(
              height: 15,
            ),
            sourceForm(context),
            const SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () => {},
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Pick a genre',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () => {},
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Choose audio file',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            uploadButton(context),
            const SizedBox(
              height: 40,
            ),
          ],
        ),

        // children: [

        //   ElevatedButton(
        //     onPressed: () => getsong(),
        //     child: const Text("Upload Song"),
        //   ),
        //   const SizedBox(
        //     height: 10,
        //   ),
        //   const SizedBox(
        //     height: 10,
        //   ),
        // ],
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: Text("Upload",
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      backgroundColor: const Color(0xff262525),
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

Container titleForm(context) {
  return Container(
    width: 350,
    height: 40,
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xff34B771),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20)),
    child: TextFormField(
      style: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 17,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        hintText: "Title",
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
      ),
    ),
  );
}

Container writersForm(context) {
  return Container(
    width: 350,
    height: 80,
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xff34B771),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20)),
    child: TextFormField(
      style: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 17,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        hintText: "Writers",
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
      ),
    ),
  );
}

Container producersForm(context) {
  return Container(
    width: 350,
    height: 80,
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xff34B771),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20)),
    child: TextFormField(
      style: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 17,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        hintText: "Producers",
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
      ),
    ),
  );
}

Container languangeForm(context) {
  return Container(
    width: 350,
    height: 40,
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xff34B771),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20)),
    child: TextFormField(
      style: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 17,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        hintText: "Language",
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
      ),
    ),
  );
}

Container sourceForm(context) {
  return Container(
    width: 350,
    height: 40,
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xff34B771),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20)),
    child: TextFormField(
      style: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 17,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        hintText: "Source",
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
      ),
    ),
  );
}

Container uploadButton(context) {
  return Container(
    width: 318,
    height: 63,
    decoration: BoxDecoration(
        color: const Color(0xfffca311),
        borderRadius: BorderRadius.circular(60)),
    child: TextButton(
      onPressed: () {},
      child: Text(
        'UPLOAD FILE',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
