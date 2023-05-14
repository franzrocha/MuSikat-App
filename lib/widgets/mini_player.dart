import 'package:flutter/material.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:provider/provider.dart';

import '../music_player/music_player.dart';
import '../service_locators.dart';

class MiniPlayer extends StatelessWidget {
  final MusicHandler musicHandler;
  const MiniPlayer({super.key, required this.musicHandler});

  //Lift MusicPlayer controller up, upto the common parent widget of both nav bar and music player (screen)
  //aron usa ra iyang controller, to which same ra ang ilang ma play nga music

  listenStateStream() {}

  MusicHandler get _musicHandler => musicHandler;

  @override
  Widget build(BuildContext context) {
    //final MusicHandler _musicHandler = locator<MusicHandler>();

    const double borderRadius = 10;
    return AnimatedBuilder(
        animation: _musicHandler,
        builder: (BuildContext context, Widget? child) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                  bottomLeft: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
                color: Color.fromARGB(255, 29, 28, 28)),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01),
            width: double.infinity,
            height: 70,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.height * 0.005,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MusicPlayerScreen(
                          songs: _musicHandler.currentSongs,
                          initialIndex: _musicHandler.currentIndex),
                    ),
                  );
                },
                child: Row(
                  children: [
                    // Thumbnail
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        child: Image(
                          image: NetworkImage(_musicHandler
                                  .currentSong?.albumCover ??
                              "https://www.nicepng.com/png/detail/933-9332131_profile-picture-default-png.png"),
                        ),
                      ),
                    ),
                    // Text
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 1, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                height: 10), // SizedBox above the title
                            MarqueeText(
                              text: TextSpan(
                                text: _musicHandler.currentSong?.title ??
                                    "No Songs Played",
                              ),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              marqueeDirection: MarqueeDirection.rtl,
                              speed: 25,
                            ),

                            Text(
                              _musicHandler.currentSong?.artist ?? "",
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 102, 101, 101)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Button
                    Expanded(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                            colors: [
                              Color(0xfffca311),
                              Color(0xff62DD69),
                            ], // Define your gradient colors here
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(
                              110)), // Adjust the radius as needed
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_musicHandler.isPlaying) {
                                _musicHandler.player.pause().then((_) {
                                  _musicHandler.isPlaying = false;
                                  _musicHandler.notifyListeners();
                                });
                              } else {
                                if (_musicHandler.currentSong != null) {
                                  _musicHandler.player.play().then((_) {
                                    _musicHandler.isPlaying = true;
                                    _musicHandler.notifyListeners();
                                  });
                                } else {
                                  // Play the first song or handle the case when no song is available
                                  if (_musicHandler.currentSongs.isNotEmpty) {
                                    _musicHandler
                                        .setAudioSource(
                                            _musicHandler.currentSongs.first,
                                            "your_uid")
                                        .then((_) {
                                      _musicHandler.isPlaying = true;
                                      _musicHandler.notifyListeners();
                                    });
                                  } else {
                                    // Handle the case when there are no songs in the currentSongs list
                                  }
                                }
                              }
                            },
                            child: Center(
                              child: Icon(
                                _musicHandler.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors
                                    .white, // Set the color of the icon here
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
