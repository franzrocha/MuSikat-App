import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:musikat_app/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UploadScreen extends StatefulWidget {
  static const String route = 'artists-screen';
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // String? imagepath;

  bool showSpinner = false;
  final uploadRef = FirebaseDatabase.instance.ref().child('Upload');

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _image;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final picker = ImagePicker();

  final TextEditingController _titleCon = TextEditingController();
  final TextEditingController _writerCon = TextEditingController();
  final TextEditingController _producerCon = TextEditingController();
  final TextEditingController _languageCon = TextEditingController();
  final TextEditingController _sourceCon = TextEditingController();

  Future getImageGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('no image selected');
      }
    });
  }

  Future getCameraImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('no image selected');
      }
    });
  }

  void dialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    InkWell(
                        onTap: () {
                          getImageGallery();
                          Navigator.pop(context);
                        },
                        child: const ListTile(
                          leading: Icon(Icons.photo_library),
                          title: Text('Gallery'),
                        )),
                    InkWell(
                        onTap: () {
                          getCameraImage();
                          Navigator.pop(context);
                        },
                        child: const ListTile(
                          leading: Icon(Icons.camera),
                          title: Text('Camera'),
                        )),
                  ],
                )),
          );
        });
  }

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
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: appbar(context),
        backgroundColor: musikatBackgroundColor,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  dialog(context);
                },
                child: Center(
                  child: Container(
                    child: _image != null
                        ? ClipRect(
                            child: Image.file(
                              _image!.absolute,
                              width: 198,
                              height: 189,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10)),
                            width: 198,
                            height: 189,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
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
              titleForm(),
              const SizedBox(
                height: 15,
              ),
              writersForm(),
              const SizedBox(
                height: 15,
              ),
              producersForm(),
              const SizedBox(
                height: 15,
              ),
              languagesForm(),
              const SizedBox(
                height: 15,
              ),
              sourceForm(),
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
              uploadButton(),
              const SizedBox(
                height: 40,
              )
            ],
          ),
        ),
      ),
    );

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
  }

  Container uploadButton() {
    return Container(
      width: 318,
      height: 63,
      decoration: BoxDecoration(
          color: const Color(0xfffca311),
          borderRadius: BorderRadius.circular(60)),
      child: TextButton(
        onPressed: () {
          () async {
            setState(() {
              showSpinner = true;
            });

            try {
              int date = DateTime.now().microsecondsSinceEpoch;

              firebase_storage.Reference ref = firebase_storage
                  .FirebaseStorage.instance
                  .ref('/musikat-app$date');

              UploadTask uploadTask = ref.putFile(_image!.absolute);
              await Future.value(uploadTask);
              var newUrl = await ref.getDownloadURL();

              final User? user = _auth.currentUser;
              uploadRef.child("Upload List").child(date.toString()).set({
                'uId': date.toString(),
                'uImage': newUrl.toString(),
                'uTime': date.toString(),
                'uTitle': _titleCon.toString(),
                'uWriters': _writerCon.toString(),
                'uEmail': user!.email.toString(),
                'uID': user.uid.toString(),
                'uProducer': _producerCon.toString(),
                'uLanguage': _languageCon.toString(),
                'uSource': _sourceCon.toString(),
                // 'uGenre': date.toString(),
                // 'uMusic': date.toString(),
              }).then((value) {
                toastMessage('Upload Published');
                //print("Upload success");
                setState(() {
                  showSpinner = false;
                });
              }).onError((error, stackTrace) {
                toastMessage(error.toString());
                setState(() {
                  showSpinner = false;
                });
              });
            } catch (e) {
              setState(() {
                showSpinner = false;
              });
              toastMessage(e.toString());
            }
          };
        },
        child: Text('UPLOAD FILE',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            )),
      ),
    );
  }

  void toastMessage(String message) {
    Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        fontSize: 16.0);
  }

  Container sourceForm() {
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
        controller: _sourceCon,
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

  Container languagesForm() {
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
        controller: _languageCon,
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

  Container producersForm() {
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
        controller: _producerCon,
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

  Container writersForm() {
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
        controller: _writerCon,
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

  Container titleForm() {
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
        controller: _titleCon,
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
