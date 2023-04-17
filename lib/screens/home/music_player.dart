import 'package:flutter/services.dart';

import 'package:just_audio_background/just_audio_background.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/utils/ui_exports.dart';
import 'package:musikat_app/utils/widgets_export.dart';

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
  final AudioPlayer player = AudioPlayer();
  final songService = SongService();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentIndex = 0;

  bool isPlaying = false;
  bool isLoadingAudio = false;
  bool _isFavorite = false;
  bool _isShuffleClicked = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex ?? 0;
    setAudio();
    player.playerStateStream.listen((playerState) async {
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
    player.playerStateStream.listen((_) {}).cancel();
    player.durationStream.listen((_) {}).cancel();
    player.positionStream.listen((_) {}).cancel();
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
    player.setLoopMode(LoopMode.off);
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
    position = Duration.zero; // Reset position to zero
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
    position = Duration.zero;
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
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      color: const Color.fromARGB(255, 124, 131, 127),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image:
                          NetworkImage(widget.songs[currentIndex].albumCover),
                      fit: BoxFit.cover, //change image fill type
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 23, right: 23),
              child: Row(
                children: [
                  Expanded(
                    child: MarqueeText(
                      text: TextSpan(
                        text: widget.songs[currentIndex].title,
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: musikatColor),
                      marqueeDirection: MarqueeDirection.rtl,
                      speed: 25,
                    ),
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
                  //  await player.play();
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isShuffleClicked = !_isShuffleClicked;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    side: const BorderSide(color: Colors.white),
                    backgroundColor: _isShuffleClicked ? Colors.white : null,
                  ),
                  child: Icon(
                    Icons.shuffle,
                    color: _isShuffleClicked ? Colors.black : Colors.white,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 35),
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
                Container(),
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;
                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 64.0,
                        height: 64.0,
                        child: const LoadingIndicator(),
                      );
                    } else if (playing != true) {
                      return Container(
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
                          icon: const Icon(Icons.play_arrow),
                          iconSize: 64.0,
                          onPressed: player.play,
                        ),
                      );
                    } else if (processingState != ProcessingState.completed) {
                      // playNext();
                      return Container(
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
                          icon: const Icon(Icons.pause),
                          iconSize: 64.0,
                          onPressed: player.pause,
                        ),
                      );
                    } else if (processingState == ProcessingState.completed) {
                      playNext();
                      return const LoadingIndicator();
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.replay),
                        iconSize: 64.0,
                        onPressed: () => player.seek(Duration.zero),
                      );
                    }
                  },
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
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                    size: 35.0,
                  ),
                ),
              ],
            )
          ]),
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
