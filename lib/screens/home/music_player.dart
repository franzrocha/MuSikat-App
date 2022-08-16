import 'dart:ffi';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({Key? key, required this.title}) : super(key: key);

  final String title;

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

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    player.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
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

  Future setAudio() async {
    player.setReleaseMode(ReleaseMode.LOOP);
    final players = AudioCache(prefix: 'assets/audio/');
    final url = await players.load('desiree.mp3');
    player.setUrl(url.path, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(context),
        backgroundColor: musikatBackgroundColor,
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: const Color.fromARGB(255, 124, 131, 127),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          image: const DecorationImage(
                            image: AssetImage("assets/images/albumdes.jpg"),
                            fit: BoxFit.cover, //change image fill type
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: Row(
                    children: const [
                      Text(
                        "where do we go now?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: Row(
                    children: const [
                      Text(
                        "Desiree Armojallas",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
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
                    thumbColor: buttonColor,
                    overlayColor: Color.fromRGBO(255, 240, 210, 0.5),
                  ),
                  child: Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await player.seek(position);

                      await player.resume();
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            await player.resume();
                          }
                        },
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LYRICS',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 70),
                    const FaIcon(
                      FontAwesomeIcons.heart,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 80),
                    Text(
                      'INFO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            )));
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
