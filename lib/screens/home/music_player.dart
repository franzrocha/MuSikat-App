import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/models/song_model.dart';
<<<<<<< Updated upstream
import 'package:just_audio/just_audio.dart';
=======
import 'package:musikat_app/services/song_service.dart';
>>>>>>> Stashed changes


  class MusicPlayerScreen extends StatefulWidget {
    final SongModel song;

  const MusicPlayerScreen({Key? key, required this.song}) : super(key: key);

<<<<<<< Updated upstream
    @override
    State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
  }
=======
class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
<<<<<<< Updated upstream
  final player = AudioPlayer();
  bool isPlaying = false; 
=======
  //final player = AudioPlayer();

  AudioPlayer player = AudioPlayer();

  //AudioCache cache = AudioCache();
  bool isPlaying = false;
>>>>>>> Stashed changes
>>>>>>> Stashed changes

  class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
    final player = AudioPlayer();
    bool isPlaying = false; 

    Duration duration = Duration.zero;
    Duration position = Duration.zero;

    @override
    void initState() {
      setAudio();

      super.initState();

    player.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
<<<<<<< Updated upstream
          isPlaying = playerState.playing;
=======
          isPlaying = state == PlayerState.playing;
>>>>>>> Stashed changes
        });
      }
    });

    player.durationStream.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration ?? Duration.zero;
        });
      }
    });

<<<<<<< Updated upstream
  player.positionStream.listen((newPosition) {
=======
    player.onPositionChanged.listen((newPosition) {
>>>>>>> Stashed changes
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
  }

<<<<<<< Updated upstream
    @override
    void dispose() {
      player.dispose();
      player.playerStateStream.listen(null);
      player.durationStream.listen(null);
      player.positionStream.listen(null);
      super.dispose();
    }
=======
  @override
  void dispose() {
    player.dispose();
    player.onPlayerStateChanged.listen(null);
    player.onDurationChanged.listen(null);
    player.onPositionChanged.listen(null);
    super.dispose();
  }
>>>>>>> Stashed changes

    String time(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));

      return [
        if (duration.inHours > 0) hours,
        minutes,
        seconds,
      ].join(":");
    }

  Future<void> setAudio() async {
<<<<<<< Updated upstream
    player.setLoopMode(LoopMode.one);
    await player.setUrl(widget.song.audio);
    await player.play();
=======
    //await player.play(widget.song.audio);
    player.setReleaseMode(ReleaseMode.loop);
>>>>>>> Stashed changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(context),
        backgroundColor: musikatBackgroundColor,
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 310,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: const Color.fromARGB(255, 124, 131, 127),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: NetworkImage(widget.song.albumCover),
                            fit: BoxFit.cover, //change image fill type
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: Row(
                      children: [
                        Text(
                          widget.song.title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: Row(
                      children: [
                        Text(
                          widget.song.writers.first,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SliderTheme(
                    data: const SliderThemeData(
                      thumbColor: musikatColor,
                      overlayColor: Color.fromRGBO(255, 240, 210, 0.5),
                    ),
                    child: Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await player.seek(position);

                        await player.play();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          time(position),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          time(duration - position),
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.backwardStep,
                        size: 35,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 30),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                            colors: [
                              Color(0xfffca311),
                              Color(0xff62DD69),
                            ],
                          ),
                          border: Border.all(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          color: const Color.fromARGB(255, 26, 25, 25),
                          onPressed: () async {
                            if (isPlaying) {
                              await player.pause();
                            } else {
                              await player.play();
                            }
                          },
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 50,
                        ),
                      ),
                      const SizedBox(width: 30),
                      const FaIcon(
                        FontAwesomeIcons.forwardStep,
                        size: 35,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //children: [
                    // Text(
                    //   'LYRICS',
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.inter(
                    //     color: Colors.white,
                    //     fontSize: 20,
                    //   ),
                    // ),
                    // const SizedBox(width: 50),
                    // const FaIcon(
                    //   FontAwesomeIcons.heart,
                    //   color: Colors.white,
                    // ),
                    // const SizedBox(width: 50),
                    // Text(
                    //   'INFO',
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.inter(
                    //     color: Colors.white,
                    //     fontSize: 20,
                    //   ),
                    // ),
                    //  ],
                  ),
                ],
              )),
        ));
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      centerTitle: true,
      title: Text("Now Playing",
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const FaIcon(
          FontAwesomeIcons.angleLeft,
          size: 20,
        ),
      ),
    );
  }
}
