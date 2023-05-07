// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class FERScreen extends StatefulWidget {
//   const FERScreen({Key? key}) : super(key: key);

//   @override
//   _FERScreenState createState() => _FERScreenState();
// }

// class _FERScreenState extends State<FERScreen> {
//   CameraController? _controller;
//    Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _setupCameraController();
//   }

//   @override
//   void dispose() {
//     _controller!.dispose();
//     super.dispose();
//   }

//   Future<void> _setupCameraController() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;
//     _controller = CameraController(
//       firstCamera,
//       ResolutionPreset.medium,
//     );
//     _initializeControllerFuture = _controller!.initialize();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return CameraPreview(_controller!);
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
