// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:musikat_app/models/song_model.dart';

// class MusicPlayer extends StatefulWidget {
//   final SongModel song;

//   const MusicPlayer({required this.song});

//   @override
//   _MusicPlayerState createState() => _MusicPlayerState();
// }

// class _MusicPlayerState extends State<MusicPlayer> {
//   late AudioPlayer audioPlayer;
//   late Duration duration;
//   late Duration position;
//   bool isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     audioPlayer = AudioPlayer();
//     audioPlayer.onDurationChanged.listen((Duration d) {
//       setState(() {
//         duration = d;
//       });
//     });
//     audioPlayer.onAudioPositionChanged.listen((Duration p) {
//       setState(() {
//         position = p;
//       });
//     });
//     play();
//   }

//   void play() async {
//     await audioPlayer.play(widget.song.audio);
//     setState(() {
//       isPlaying = true;
//     });
//   }

//   void pause() async {
//     await audioPlayer.pause();
//     setState(() {
//       isPlaying = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.song.title),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 250,
//             height: 250,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(125),
//               image: DecorationImage(
//                 image: NetworkImage(widget.song.albumCover),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(height: 50),
//           Text(
//             position != null
//                 ? '${position.inMinutes.remainder(60)}:${position.inSeconds.remainder(60).toString().padLeft(2, '0')} / ${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}'
//                 : '',
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 onPressed: isPlaying ? pause : play,
//                 icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }
// }
