// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musikat_app/music_player/player_controls.dart';
import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:provider/provider.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<SongModel> songs;
  final int? initialIndex;

  const MusicPlayerScreen({
    Key? key,
    required this.songs,
    this.initialIndex,
  }) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final LikedSongsController likedCon = LikedSongsController();
  final AudioPlayer player = AudioPlayer();

  final songService = SongService();
  final MusicHandler musicHandler = MusicHandler();
  int currentIndex = 0;

  bool isPlaying = false;
  bool isLoadingAudio = false;

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex ?? 0;
    musicHandler.setAudioSource(player, widget.songs[currentIndex]);

    checkIfSongIsLiked();
  }

  void checkIfSongIsLiked() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    bool isLiked = await likedCon.isSongLikedByUser(
        widget.songs[currentIndex].songId, uid);
    setState(() {
      _isLiked = isLiked;
    });
  }

  @override
  void dispose() {
    player.dispose();
    // musicHandler.dispose();
    super.dispose();
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
      checkIfSongIsLiked();
      await musicHandler.setAudioSource(player, widget.songs[currentIndex]);
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await musicHandler.setAudioSource(player, widget.songs[currentIndex]);
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
      checkIfSongIsLiked();
      await musicHandler.setAudioSource(player, widget.songs[currentIndex]);
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await musicHandler.setAudioSource(player, widget.songs[currentIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MusicHandler(),
      child: Scaffold(
        appBar: appbar(context),
        backgroundColor: musikatBackgroundColor,
        body:
            Consumer<MusicHandler>(builder: (context, musicController, child) {
          return SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(
                children: [
                  Container(
                    width: 320,
                    height: 320,
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
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 23, right: 23, top: 25),
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
                            color: Colors.white),
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
                      widget.songs[currentIndex].artist,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SliderControls(player: player),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      size: 35,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SliderDialog(
                          title: "Adjust volume",
                          divisions: 100,
                          min: 0,
                          max: 1,
                          value: player.volume,
                          stream: player.volumeStream,
                          onChanged: player.setVolume,
                          context: context,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 35),
                  
                  InkWell(
                    onTap: () async {
                      await playPrevious();
                    },
                    child: const FaIcon(
                      FontAwesomeIcons.backwardStep,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 30),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing;
                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return Container(
                          margin: const EdgeInsets.all(9.0),
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
                        BoxDecoration(
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
                        );
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
                    onTap: () async {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      String uid = FirebaseAuth.instance.currentUser!.uid;
                      if (_isLiked) {
                        await likedCon.addLikedSong(
                          uid,
                          widget.songs[currentIndex].songId,
                        );
                        ToastMessage.show(context, 'Song added to liked songs');
                      } else {
                        await likedCon.removeLikedSong(
                          uid,
                          widget.songs[currentIndex].songId,
                        );
                        ToastMessage.show(
                            context, 'Song removed from liked songs');
                      }
                    },
                    child: FaIcon(
                      _isLiked
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      color: _isLiked ? Colors.red : Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              )
            ]),
          ));
        }),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      centerTitle: true,
      title: Text("Now Playing",
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
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
