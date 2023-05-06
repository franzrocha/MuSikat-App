// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex ?? 0;
    musicHandler.setAudioSource(player, widget.songs[currentIndex], uid);

    checkIfSongIsLiked();
  }

  void checkIfSongIsLiked() async {
    bool isLiked = await likedCon.isSongLikedByUser(
        widget.songs[currentIndex].songId, uid);
    setState(() {
      _isLiked = isLiked;
    });
  }

  @override
  void dispose() {
    player.dispose();
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
      await musicHandler.setAudioSource(
          player, widget.songs[currentIndex], uid);
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await musicHandler.setAudioSource(
          player, widget.songs[currentIndex], uid);
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
      await musicHandler.setAudioSource(
          player, widget.songs[currentIndex], uid);
    } on PlayerInterruptedException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      await musicHandler.setAudioSource(
          player, widget.songs[currentIndex], uid);
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
              child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.8, // set width to 90% of screen width
                        height: MediaQuery.of(context).size.width *
                            0.8, // set height to 90% of screen width
                        // other properties

                        decoration: BoxDecoration(
                          color: musikatBackgroundColor,
                          border: Border.all(
                            color: const Color.fromARGB(255, 124, 131, 127),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: NetworkImage(
                                widget.songs[currentIndex].albumCover),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 23, right: 23, top: 25),
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
                        height: 10,
                      ),
                      SliderControls(player: player),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              size: 25,
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
                          const SizedBox(width: 25),
                          InkWell(
                            onTap: () async {
                              await playPrevious();
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.backwardStep,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 25),
                          StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(9.0),
                                  width: 50,
                                  height: 50,
                                  child: const LoadingIndicator(),
                                );
                              } else if (playing != true) {
                                return playButton();
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return pauseButton();
                              } else if (processingState ==
                                  ProcessingState.completed) {
                                playNext();
                                return const LoadingIndicator();
                              } else {
                                return pauseButton();
                              }
                            },
                          ),
                          const SizedBox(width: 25),
                          InkWell(
                            onTap: () {
                              playNext();
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.forwardStep,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 30),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                _isLiked = !_isLiked;
                              });
                              String uid =
                                  FirebaseAuth.instance.currentUser!.uid;
                              if (_isLiked) {
                                await likedCon.addLikedSong(
                                  uid,
                                  widget.songs[currentIndex].songId,
                                );
                                await FirebaseFirestore.instance
                                    .collection('songs')
                                    .doc(widget.songs[currentIndex].songId)
                                    .update(
                                        {'likeCount': FieldValue.increment(1)});
                                ToastMessage.show(
                                    context, 'Song added to liked songs');
                              } else {
                                await likedCon.removeLikedSong(
                                  uid,
                                  widget.songs[currentIndex].songId,
                                );
                                await FirebaseFirestore.instance
                                    .collection('songs')
                                    .doc(widget.songs[currentIndex].songId)
                                    .update({
                                  'likeCount': FieldValue.increment(-1)
                                });

                                ToastMessage.show(
                                    context, 'Song removed from liked songs');
                              }
                            },
                            child: FaIcon(
                              _isLiked
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              color: _isLiked ? Colors.red : Colors.white,
                              size: 25,
                            ),
                          ),
                        ],
                      )
                    ]),
              ),
            ),
          ));
        }),
      ),
    );
  }

  Container pauseButton() {
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
        iconSize: 50,
        onPressed: player.pause,
      ),
    );
  }

  Container playButton() {
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
        iconSize: 50,
        onPressed: player.play,
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
