// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  @override
  Widget build(BuildContext context) {
    final SongsController _songsCon = SongsController();

    int length;
    Random random = Random();
    int randomIndex = 0;

    if (cameraController != null && cameraController!.value.isInitialized) {
      return Scaffold(
        backgroundColor: musikatBackgroundColor,
        body: Stack(
          children: [
            CameraPreview(cameraController!),
            GestureDetector(
              onTap: () {
                setState(() {
                  direction = direction == 0 ? 1 : 0;
                  startCamera(direction);
                });
              },
              child:
                  button(Icons.flip_camera_ios_outlined, Alignment.bottomLeft),
            ),
            GestureDetector(
              onTap: () async {
                cameraController?.takePicture().then((XFile? file) async {
                  if (mounted && file != null) {
                    print(file.path);
                    String fileName =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    Reference ref = storage.ref().child('images/$fileName.jpg');
                    UploadTask uploadTask = ref.putFile(File(file.path));

                    TaskSnapshot taskSnapshot = await uploadTask;
                    String downloadUrl =
                        await taskSnapshot.ref.getDownloadURL();
                    print(downloadUrl);

                    // Display the captured image in a dialog or modal bottom sheet
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Captured Image'),
                        content: Column(
                          children: [
                            Image.network(downloadUrl),
                            const SizedBox(height: 10),
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
                                'Create a Playlist',
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
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // User marked the picture as not okay
                                // Perform necessary actions
                                Navigator.pop(context); // Close the dialog
                              },
                              child: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                    );

                    // Call the API with the download URL
                    Uri apiUrl = Uri.parse(
                        'https://627e-2001-4454-399-2500-204e-163e-df1b-1a1a.ngrok-free.app/?image=$downloadUrl');
                    http.Response response = await http.get(apiUrl);

                    if (response.statusCode == 200) {
                      emotion = response.body;
                      songs = await _songCon.getEmotionSongs(emotion);
                      length = songs.length;
                      randomIndex = random.nextInt(length);

                      // API call successful
                      // print('API response: ${response.body}');
                      Fluttertoast.showToast(
                          msg: 'It seems that you are ${response.body} today!');
                    } else {
                      // API call failed
                      print(
                          'API call failed with status code: ${response.statusCode}');
                      Fluttertoast.showToast(msg: 'Failed to call API');
                    }
                  }
                });
              },
              child: button(Icons.camera_alt_outlined, Alignment.bottomCenter),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Text("FER Camera",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                    )),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget button(IconData icon, Alignment alignment) {
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
            ], // Define your gradient colors here
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
