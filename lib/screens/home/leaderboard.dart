// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:musikat_app/controllers/songs_controller.dart';
// import 'package:musikat_app/models/song_model.dart';
// import 'package:musikat_app/utils/exports.dart';

// class Leaderboard extends StatefulWidget {
//   const Leaderboard({super.key});

//   @override
//   State<Leaderboard> createState() => _LeaderboardState();
// }

// class _LeaderboardState extends State<Leaderboard> {

//   final SongsController _songCon = SongsController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: musikatBackgroundColor,
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder(
//               future:
//                   _songCon.getRanked(FirebaseAuth.instance.currentUser!.uid),
//               builder: (BuildContext context,
//                   AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
//                 if (snapshot.hasData) {
//                   final List<Map<String, dynamic>> rankedSongs = snapshot.data!;
//                   if (rankedSongs.isEmpty) {
//                     return Center(
//                       child: Text(
//                         'No songs found in your library.',
//                         style: shortThinStyle,
//                       ),
//                     );
//                   }
          
//                   return ListView.separated(
//                     itemCount: rankedSongs.length,
//                     separatorBuilder: (BuildContext context, int index) =>
//                         const SizedBox(height: 10),
//                     itemBuilder: (BuildContext context, int index) {
//                       final SongModel song = rankedSongs[index]['song'];
//                       final double percentageScore =
//                           rankedSongs[index]['percentageScore'];
          
//                       return ListTile(
//                         leading: Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image:
//                                   CachedNetworkImageProvider(song.albumCover),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           '${index + 1}.  ${song.title}',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: songTitle,
//                         ),
//                         subtitle: Text(
//                           'Percentage Score: ${percentageScore.toStringAsFixed(2)}%',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(
//                     child: Text('Error: ${snapshot.error}'),
//                   );
//                 } else {
//                   return const Center(
//                     child: LoadingIndicator(),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }