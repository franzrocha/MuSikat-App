// import 'package:musikat_app/music_player/audio_handler.dart';
// import '../utils/exports.dart';

// class MyMusicPlayer extends StatefulWidget {
//   const MyMusicPlayer({super.key});

//   @override
//   State<MyMusicPlayer> createState() => _MyMusicPlayerState();
// }

// class _MyMusicPlayerState extends State<MyMusicPlayer> {

//   final AudioHandler audioHandler = AudioHandler();

//   @override
//   void initState() {
//     super.initState();
//     // audioHandler.loadAsset('assets/audio/desiree.mp3');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Audio Player Demo',
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter Audio Player Demo'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               IconButton(
//                 icon: const Icon(Icons.play_arrow),
//                 onPressed: () async {
//                   // await audioService.playAsset('assets/audio/desiree.mp3');
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
