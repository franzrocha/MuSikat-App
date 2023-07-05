// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

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

    cameraController?.pausePreview();

    cameraController?.takePicture().then((XFile? file) async {
      if (mounted && file != null) {
        print(file.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = storage.ref().child('images/$fileName.jpg');
        UploadTask uploadTask = ref.putFile(File(file.path));

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print(downloadUrl);

        // Create an instance of InputImage from the file path
        // InputImage inputImage = InputImage.fromFilePath(file.path);

        // // Create an instance of FaceDetector
        // FaceDetector faceDetector = GoogleMlKit.vision.faceDetector();

        // // Process the input image for face detection
        // List<Face> faces = await faceDetector.processImage(inputImage);

        // Check if any faces were detected
        // if (faces.isNotEmpty) {
          // Call the API with the download URL
          Uri apiUrl = Uri.parse(
              'https://d6db-49-145-99-111.ngrok-free.app/?image=$downloadUrl');
          http.Response response = await http.get(apiUrl);

          if (response.statusCode == 200) {
            emotion = response.body;
            songs = await _songCon.getEmotionSongs(emotion);
            int length = songs.length;
            Random random = Random();
            int randomIndex = random.nextInt(length);

            // API call successful
            // print('API response: ${response.body}');

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
            ToastMessage.show(context, 'Failed to call API');
          }
        } else {
          // No face detected
          ToastMessage.show(context, 'No face detected');
        }

        setState(() {
          isCapturing = false;
        });

        cameraController?.resumePreview();
      
    });
  }

  void updateFocusPoint(Offset point) {
    setState(() {
      focusPoint = point;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final SongsController _songsCon = SongsController();

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
                    size: 60,
                  ),
                ),
              ),
            // GestureDetector(
            //   onTap: () {
            //     setState(() {
            //       direction = direction == 0 ? 1 : 0;
            //       startCamera(direction);
            //     });
            //   },
            //   child: button(
            //       Icons.flip_camera_ios_outlined, Alignment.bottomLeft, () {
            //     // Callback function logic goes here
            //   }),
            // ),
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
                      children: [
                        const LoadingIndicator(),
                        const SizedBox(height: 10),
                        Text(
                          'Detecting emotion...',
                          style: sloganStyle,
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

class CameraResultScreen extends StatefulWidget {
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
  State<CameraResultScreen> createState() => _CameraResultScreenState();
}

class _CameraResultScreenState extends State<CameraResultScreen> {
  final SongsController songCon = SongsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        showLogo: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 35,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: musikatColor,
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      elevation: 0,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(height: 500, child: Image.network(widget.downloadUrl)),
            const SizedBox(height: 30),
            Text(
              'It seems that you are ${widget.response} today ${getEmojiForResponse(widget.response)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Gotham',
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                    color: musikatColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MusicPlayerScreen(
                            songs: widget.songs,
                            emotion: widget.emotion,
                            initialIndex: widget.randomIndex,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Play a song",
                      style: shortDefault,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                    color: musikatColor2,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                          backgroundColor: musikatColor4,
                          context: context,
                          builder: (BuildContext context) {
                            return SingleChildScrollView(
                              child: Material(
                                color: musikatBackgroundColor,
                                child: SafeArea(
                                  top: false,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                    ),
                                    child: Column(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerRight,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(Icons.close,
                                                  color: Colors.white)),
                                        ),
                                        Text(
                                            getTextForEmotion(widget.emotion,
                                                widget.response),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Gotham')),
                                        const SizedBox(height: 20),
                                        Expanded(
                                          child: FutureBuilder<List<SongModel>>(
                                            future: songCon.getEmotionSongs(
                                                widget.emotion),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child: LoadingIndicator());
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        'Error: ${snapshot.error}'));
                                              } else {
                                                final descriptionSongs =
                                                    snapshot.data!;
                                                final limitedSongs =
                                                    descriptionSongs.length > 5
                                                        ? descriptionSongs
                                                            .sublist(0, 5)
                                                        : descriptionSongs;

                                                final random = Random();

                                                limitedSongs.shuffle(random);

                                                return limitedSongs.isEmpty
                                                    ? Center(
                                                        child: Text(
                                                          "No songs found related \nto $widget.emotion yet.",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    : ListView.builder(
                                                        itemCount:
                                                            limitedSongs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final song =
                                                              limitedSongs[
                                                                  index];

                                                          return ListTile(
                                                            leading: Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: CachedNetworkImageProvider(
                                                                      song.albumCover),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            title: Text(
                                                              song.title,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            subtitle: Text(
                                                                song.artist,
                                                                style: GoogleFonts.inter(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.5),
                                                                    fontSize:
                                                                        14)),
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MusicPlayerScreen(
                                                                              songs: descriptionSongs,
                                                                              initialIndex: index,
                                                                            )),
                                                              );
                                                            },
                                                            onLongPress: () {
                                                              showModalBottomSheet(
                                                                  backgroundColor:
                                                                      musikatColor4,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return SingleChildScrollView(
                                                                      child:
                                                                          SongBottomField(
                                                                        song:
                                                                            song,
                                                                        hideRemoveToPlaylist:
                                                                            true,
                                                                        hideDelete:
                                                                            true,
                                                                        hideEdit:
                                                                            true,
                                                                        hideLike:
                                                                            false,
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                          );
                                                        },
                                                      );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                    child: Text(
                      "Suggested songs",
                      style: shortDefault,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  String getTextForEmotion(String emotion, String response) {
    String emoji = getEmojiForResponse(response);

    if (emotion == 'happy') {
      return 'Here are some songs to make you feel even happier $emoji';
    } else if (emotion == 'sad') {
      return 'Here are some songs to help you feel a little better $emoji';
    } else if (emotion == 'normal') {
      return 'Here are some songs to enjoy $emoji';
    } else if (emotion == 'angry') {
      return 'Here are some songs to help you vent your anger $emoji';
    } else {
      return 'Here are some songs for your current emotion $emoji';
    }
  }

  String getEmojiForResponse(String response) {
    switch (response) {
      case 'happy':
        return '😄';
      case 'sad':
        return '😢';
      case 'normal':
        return '😐';
      case 'angry':
        return '😡';
      default:
        return '';
    }
  }
}
