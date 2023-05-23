import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/song_charts.dart';

import 'package:musikat_app/utils/exports.dart';

class InsightsScreen extends StatefulWidget {
  static const String route = 'artists-screen';

  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final SongsController _songCon = SongsController();
  UserModel? user;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Tracks'),
            ],
          ),
          backgroundColor:
              musikatBackgroundColor, // Customize the background color of the app bar
        ),
        backgroundColor: musikatBackgroundColor,
        body: SafeArea(
          child: TabBarView(
            children: [
              // Content for the first tab (Top Tracks)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      height: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Top Tracks',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: FutureBuilder(
                      future: _songCon.getRankedSongs(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<SongModel>> snapshot) {
                        if (snapshot.hasData) {
                          final List<SongModel> songs = snapshot.data!
                              .where((song) =>
                                  song.uid ==
                                  FirebaseAuth.instance.currentUser?.uid)
                              .toList();
                          return ListView.separated(
                            itemCount: songs.length > 5 ? 5 : songs.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              final SongModel song = songs[index];
                              return ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SongPlayCountChart(songs: songs),
                                    ),
                                  );
                                },
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          song.albumCover),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          return const Center(
                            child: LoadingIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                  FutureBuilder<int>(
                    future: _songCon.getUserSongCount(),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return ListTile(
                          trailing: Text(
                            '${snapshot.data}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Songs Uploaded',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 20, indent: 1.0, color: listileColor),
                ],
              ),

              // Content for the second tab (Song Plays/Likes)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: StreamBuilder<List<SongModel>>(
                      stream: _songCon.getSongsStream(), // Retrieve all songs
                      builder: (BuildContext context,
                          AsyncSnapshot<List<SongModel>> snapshot) {
                        if (snapshot.hasData) {
                          // Filter songs by user
                          final List<SongModel> songs = snapshot.data!
                              .where((song) =>
                                  song.uid ==
                                  FirebaseAuth.instance.currentUser?.uid)
                              .toList();

                          return ListView.separated(
                            itemCount: songs.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              final SongModel song = songs[index];
                              return ListTile(
                                onTap: () {
                                  // Handle song tap
                                },
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          song.albumCover),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      song.playCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      song.likeCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          return const Center(
                            child: LoadingIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
