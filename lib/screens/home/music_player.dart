import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musikat_app/services/song_service.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<SongModel> songs;
  final String username;
  final int? initialIndex;

  const MusicPlayerScreen({
    Key? key,
    required this.songs,
    required this.username,
    this.initialIndex,
  }) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final player = AudioPlayer();
  final songService = SongService();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentIndex = 0;

  bool isPlaying = false;
  bool isLoadingAudio = false;

 @override
void initState() {
  super.initState();
  currentIndex = widget.initialIndex ?? 0;
  setAudio();
  player.playingStream.listen((isPlaying) {
    if (mounted) {
      setState(() {
        this.isPlaying = isPlaying;
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

  // Listen for when the current song finishes processing
 player.playerStateStream.listen((playerState) {
    if (playerState.playing && playerState.processingState == ProcessingState.completed) {
      if (mounted) {
        setState(() {
          // Play the next song
          currentIndex = (currentIndex + 1) % widget.songs.length;
          playNext();
        });
      }
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
    player.setLoopMode(LoopMode.all);

    final source = AudioSource.uri(
      Uri.parse(widget.songs[currentIndex].audio),
      tag: MediaItem(
        id: widget.songs[currentIndex].songId,
        title: widget.songs[currentIndex].title,
        artist: widget.username,
        artUri: Uri.parse(widget.songs[currentIndex].albumCover),
      ),
    );

    try {
    await player.setAudioSource(source);
    await player.play();
    player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  } catch (e) {
    if (e is PlatformException) {
      await Future.delayed(const Duration(seconds: 2));
      await setAudio();
    } else {
      rethrow;
    }
  }
}

  Future<void> playPrevious() async {
    if (isLoadingAudio) {
      return;
    }
    if (currentIndex > 0) {
      currentIndex--;
    } else {
      currentIndex = widget.songs.length - 1;
    }
    try {
      await setAudio();
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await setAudio();
    }
  }

  Future<void> playNext() async {
    if (isLoadingAudio) {
      return;
    }
    if (currentIndex < widget.songs.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }
    try {
      await setAudio();
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await setAudio();
    }
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
                        width: 280,
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: const Color.fromARGB(255, 124, 131, 127),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: NetworkImage(
                                widget.songs[currentIndex].albumCover),
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
                          widget.songs[currentIndex].title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: musikatColor),
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
                      InkWell(
                        onTap: () {
                          playPrevious();
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.backwardStep,
                          size: 35,
                          color: Colors.white,
                        ),
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
                      InkWell(
                        onTap: () {
                          playNext();
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.forwardStep,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                 
                  
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
