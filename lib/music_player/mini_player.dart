// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';

import '../music_player/music_player.dart';

class MiniPlayer extends StatelessWidget {
  final MusicHandler musicHandler;
  const MiniPlayer({super.key, required this.musicHandler});

  listenStateStream() {}

  // MusicHandler get musicHandler => musicHandler;

  @override
  Widget build(BuildContext context) {
    final MusicHandler musicHandler = locator<MusicHandler>();

    const double borderRadius = 10;
    return AnimatedBuilder(
        animation: musicHandler,
        builder: (BuildContext context, Widget? child) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                    bottomLeft: Radius.circular(borderRadius),
                    bottomRight: Radius.circular(borderRadius),
                  ),
                  color: Color.fromARGB(255, 24, 23, 23)),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.01),
              width: double.infinity,
              height: 50,
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
                          songs: musicHandler.currentSongs,
                          initialIndex: musicHandler.currentIndex,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              musicHandler.currentSong?.albumCover ??
                                  'https://icon-library.com/images/vinyl-icon-png/vinyl-icon-png-11.jpg',
                            ),
                            fit: BoxFit.cover,
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
                              const SizedBox(height: 5),
                              MarqueeText(
                                text: TextSpan(
                                    text: musicHandler.currentSong?.title ??
                                        "No song playing... "),
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white),
                                marqueeDirection: MarqueeDirection.rtl,
                                speed: 25,
                              ),
                              Text(
                                musicHandler.currentSong?.artist ?? "",
                                style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.5),
                                    height: 1.5,
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Button
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: [
                                Color(0xfffca311),
                                Color(0xff62DD69),
                              ], 
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(
                                110)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                print("IsPlaying: ${musicHandler.isPlaying}");
                                if (musicHandler.isPlaying) {
                                  await musicHandler.player.pause();
                                  musicHandler.setIsPlaying(false);
                                } else {
                                  if (musicHandler.currentSong != null) {
                                    musicHandler.player.play();
                                    musicHandler.setIsPlaying(true);
                                  } else {
                                    if (musicHandler.currentSongs.isNotEmpty) {
                                      musicHandler
                                          .setAudioSource(
                                              musicHandler.currentSongs.first,
                                              "your_uid")
                                          .then((_) {
                                        musicHandler.setIsPlaying(true);
                                      });
                                    } else {
                                      print("No songs available");
                                    }
                                  }
                                }
                              },
                              child: Center(
                                child: Icon(
                                  musicHandler.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors
                                      .white, 
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
            ),
          );
        });
  }
}
