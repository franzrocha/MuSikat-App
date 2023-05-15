// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/music_player/player_controls.dart';
import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/utils/exports.dart';

import '../service_locators.dart';

class MusicPlayerScreen extends StatefulWidget {
  final String? emotion;
  final int? initialIndex;

  final List<SongModel> songs;

  const MusicPlayerScreen({
    Key? key,
    this.emotion,
    this.initialIndex,
    required this.songs,
  }) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final LikedSongsController likedCon = LikedSongsController();
  final MusicHandler _musicHandler = locator<MusicHandler>();

  final songService = SongService();
  //MusicHandler get _musicHandler => widget.musicHandler!;

  bool isPlaying = false;
  bool isLoadingAudio = false;
  bool disableButton = false;

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _musicHandler.currentSongs = widget.songs;
    _musicHandler.currentIndex = widget.initialIndex ?? 0;
    _musicHandler.setAudioSource(
      widget.songs[widget.initialIndex ??
          0], // provide a default value (e.g., 0) when initialIndex is null
      uid,
    );

    print(widget.initialIndex);

    _musicHandler.checkIfSongIsLiked();
    _musicHandler.initSongStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(context),
        backgroundColor: musikatBackgroundColor,
        body: AnimatedBuilder(
          animation: _musicHandler,
          builder: (BuildContext context, Widget? child) {
            return SafeArea(
                child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            color: musikatBackgroundColor,
                            border: Border.all(
                              color: const Color.fromARGB(255, 124, 131, 127),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: NetworkImage(widget
                                  .songs[_musicHandler.currentIndex]
                                  .albumCover),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 23, right: 23, top: 25),
                          child: Row(
                            children: [
                              Expanded(
                                child: MarqueeText(
                                  text: TextSpan(
                                    text: widget
                                        .songs[_musicHandler.currentIndex]
                                        .title,
                                  ),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
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
                                widget.songs[_musicHandler.currentIndex].artist,
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
                        SliderControls(player: _musicHandler.player),
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
                                    value: _musicHandler.player.volume,
                                    stream: _musicHandler.player.volumeStream,
                                    onChanged: _musicHandler.player.setVolume,
                                    context: context,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 25),
                            InkWell(
                              onTap: !disableButton
                                  ? () async {
                                      if (!disableButton) {
                                        setState(() {
                                          disableButton = true;
                                        });
                                      }
                                      await _musicHandler.playPrevious();
                                      setState(() {
                                        disableButton = false;
                                      });
                                    }
                                  : null,
                              child: const FaIcon(
                                FontAwesomeIcons.backwardStep,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 25),
                            if (_musicHandler.isLoading) ...[
                              Container(
                                  margin: const EdgeInsets.all(9.0),
                                  width: 50,
                                  height: 50,
                                  child: const LoadingIndicator()),
                            ] else if (!_musicHandler.isPlaying) ...[
                              playButton(),
                            ] else ...[
                              pauseButton(),
                            ],
                            const SizedBox(width: 25),
                            InkWell(
                              onTap: !disableButton
                                  ? () async {
                                      if (mounted && !disableButton) {
                                        setState(() {
                                          disableButton = true;
                                        });
                                      }
                                      await _musicHandler.playNext();
                                      if (mounted) {
                                        setState(() {
                                          disableButton = false;
                                        });
                                      }
                                    }
                                  : null,
                              child: const FaIcon(
                                FontAwesomeIcons.forwardStep,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 30),
                            GestureDetector(
                              onTap: () async {
                                _musicHandler
                                    .setIsLiked(!_musicHandler.isLiked);

                                String uid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                if (_musicHandler.isLiked) {
                                  await likedCon.addLikedSong(
                                    uid,
                                    widget.songs[_musicHandler.currentIndex]
                                        .songId,
                                  );
                                  await FirebaseFirestore.instance
                                      .collection('songs')
                                      .doc(_musicHandler
                                          .currentSongs[
                                              _musicHandler.currentIndex]
                                          .songId)
                                      .update({
                                    'likeCount': FieldValue.increment(1)
                                  });
                                  ToastMessage.show(
                                      context, 'Song added to liked songs');
                                } else {
                                  await likedCon.removeLikedSong(
                                    uid,
                                    widget.songs[_musicHandler.currentIndex]
                                        .songId,
                                  );
                                  await FirebaseFirestore.instance
                                      .collection('songs')
                                      .doc(widget
                                          .songs[_musicHandler.currentIndex]
                                          .songId)
                                      .update({
                                    'likeCount': FieldValue.increment(-1)
                                  });

                                  ToastMessage.show(
                                      context, 'Song removed from liked songs');
                                }
                              },
                              child: FaIcon(
                                _musicHandler.isLiked
                                    ? FontAwesomeIcons.solidHeart
                                    : FontAwesomeIcons.heart,
                                color: _musicHandler.isLiked
                                    ? Colors.red
                                    : Colors.white,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
              ),
            ));
          },
        ));
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
        onPressed: _musicHandler.player.pause,
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
          onPressed: _musicHandler.player.play),
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
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.pop(context);
          });
        },
        icon: const FaIcon(
          FontAwesomeIcons.angleLeft,
          size: 20,
        ),
      ),
    );
  }
}
