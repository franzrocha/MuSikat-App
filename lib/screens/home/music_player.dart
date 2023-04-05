import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerScreen extends StatefulWidget {
  final SongModel song;
  final String username;

  const MusicPlayerScreen(
      {Key? key, required this.song, required this.username})
      : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

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
          isPlaying = playerState.playing;
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

    player.positionStream.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    player.playerStateStream.listen(null);
    player.durationStream.listen(null);
    player.positionStream.listen(null);
    super.dispose();
  }

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
    player.setLoopMode(LoopMode.one);

    final source = AudioSource.uri(
      Uri.parse(widget.song.audio),
      tag: MediaItem(
        id: widget.song.songId,
        title: widget.song.title,
        artist: widget.username,
        artUri: Uri.parse(widget.song.albumCover),
      ),
    );
    await player.setAudioSource(source);
    await player.play();
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
                          widget.username,
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
