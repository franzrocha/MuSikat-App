// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';

// import '../models/song_model.dart';

// class AudioPlayerScreen extends StatefulWidget {
//   final SongModel song;

//   const AudioPlayerScreen({super.key, required this.song});

//   @override
//   State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   late AudioPlayer _audioPlayer;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _audioPlayer = AudioPlayer();
//     _audioPlayer.setUrl(widget.song.audio);
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Music Player'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: Icon(
//                 _isPlaying ? Icons.pause : Icons.play_arrow,
//               ),
//               iconSize: 64.0,
//               onPressed: () {
//                 setState(() {
//                   _isPlaying = !_isPlaying;
//                   if (_isPlaying) {
//                     _audioPlayer.play();
//                   } else {
//                     _audioPlayer.pause();
//                   }
//                 });
//               },
//             ),
//             const SizedBox(height: 32.0),
//             ElevatedButton(
//               child: Text('Go to Next Screen'),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => NextScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class NextScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Next Screen'),
//       ),
//       body: Center(
//         child: Text('This is the next screen'),
//       ),
//     );
//   }
// }
