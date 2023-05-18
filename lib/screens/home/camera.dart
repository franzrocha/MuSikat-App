import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/screens/home/emotion_screen.dart';
import 'package:musikat_app/utils/exports.dart';
import '../../controllers/songs_controller.dart';

import '../../models/song_model.dart';

class CameraScreen extends StatefulWidget {
  final List<SongModel> songs;

  const CameraScreen({
    Key? key,
    required this.songs,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  late List<SongModel> songs = [];

  String emotion = '';
  late List<CameraDescription> cameras;
  CameraController? cameraController;
  final SongsController _songCon = SongsController();

  int direction = 1;
  bool isCapturing = false;
  Offset? focusPoint;

  @override
  void initState() {
    startCamera(direction);
    super.initState();
  }

  void startCamera(int direction) async {
    cameras = await availableCameras();

    cameraController = CameraController(
      cameras[direction],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController?.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> captureImage() async {
    setState(() {
      isCapturing = true;
    });

    cameraController?.takePicture().then((XFile? file) async {
      if (mounted && file != null) {
        print(file.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = storage.ref().child('images/$fileName.jpg');
        UploadTask uploadTask = ref.putFile(File(file.path));

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print(downloadUrl);

        // Call the API with the download URL
        Uri apiUrl = Uri.parse(
            'https://cba6-49-145-104-250.ngrok-free.app/?image=$downloadUrl');
        http.Response response = await http.get(apiUrl);

        if (response.statusCode == 200) {
          emotion = response.body;
          songs = await _songCon.getEmotionSongs(emotion);
          int length = songs.length;
          Random random = Random();
          int randomIndex = random.nextInt(length);

          // API call successful
          // print('API response: ${response.body}');

          // Fluttertoast.showToast(
          //     msg: 'It seems that you are ${response.body} today!');

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CameraResultScreen(
                downloadUrl: downloadUrl,
                emotion: emotion,
                songs: songs,
                randomIndex: randomIndex,
                response: response.body,
              ),
            ),
          );
        } else {
          // API call failed
          print('API call failed with status code: ${response.statusCode}');
          Fluttertoast.showToast(msg: 'Failed to call API');
        }

        setState(() {
          isCapturing = false;
        });
      }
    });
  }

  void updateFocusPoint(Offset point) {
    setState(() {
      focusPoint = point;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SongsController _songsCon = SongsController();

    if (cameraController != null && cameraController!.value.isInitialized) {
      return Scaffold(
        backgroundColor: musikatBackgroundColor,
        body: Stack(
          children: [
            CameraPreview(cameraController!),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isCapturing ? Colors.red : Colors.green,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            if (focusPoint != null)
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.yellow,
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.face,
                    color: Colors.yellow,
                    size: 48.0,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () {
                setState(() {
                  direction = direction == 0 ? 1 : 0;
                  startCamera(direction);
                });
              },
              child: button(
                  Icons.flip_camera_ios_outlined, Alignment.bottomLeft, () {
                // Callback function logic goes here
              }),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    button(Icons.camera_alt_outlined, Alignment.bottomCenter,
                        () async {
                      if (!isCapturing) {
                        await captureImage();
                      }
                    }),
                  ],
                ),
              ],
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "FER Camera",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            if (isCapturing)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        LoadingIndicator(),
                        SizedBox(height: 10),
                        Text(
                          'Musikat Generating Songs.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget button(
    IconData icon,
    Alignment alignment,
    VoidCallback onPressed,
  ) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(
          left: 20,
          bottom: 20,
        ),
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xfffca311),
              Color(0xff62DD69),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class CameraResultScreen extends StatelessWidget {
  final String downloadUrl;
  final String emotion;
  final List<SongModel> songs;
  final int randomIndex;
  final String response;

  const CameraResultScreen({
    Key? key,
    required this.downloadUrl,
    required this.emotion,
    required this.songs,
    required this.randomIndex,
    required this.response,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(downloadUrl),
          const SizedBox(height: 20),
          Text(
            'It seems that you are $response today',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EmotionDisplayScreen(
                        emotion: emotion,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Suggested Songs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MusicPlayerScreen(
                        songs: songs,
                        emotion: emotion,
                        initialIndex: randomIndex,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Play A Song',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          ElevatedButton(
            onPressed: () {
              // User marked the picture as not okay
              // Perform necessary actions
              Navigator.pop(context);
            },
            child: const Icon(Icons.close),
          ),
          const SizedBox(height: 0),
        ],
      ),
    );
  }
}
