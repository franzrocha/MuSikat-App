import 'package:just_audio/just_audio.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:provider/provider.dart';

class SliderControls extends StatefulWidget {
  const SliderControls({
    super.key,
    required this.player,
  });

  final AudioPlayer player;

  @override
  State<SliderControls> createState() => _SliderControlsState();
}

class _SliderControlsState extends State<SliderControls> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MusicHandler(),
      child: Consumer<MusicHandler>(
          builder: (context, musicController, child) {
        return StreamBuilder<Duration?>(
          stream: widget.player.durationStream,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: widget.player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return Column(
                  children: [
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
                          await widget.player.seek(position);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            musicController.time(position),
                            style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.5)),
                          ),
                          Text(
                            musicController.time(duration - position),
                            style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.5)),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      }),
    );
  }
}


// class ButtonControls extends StatefulWidget {
//   const ButtonControls({super.key, required this.player});

//   final AudioPlayer player;

//   @override
//   State<ButtonControls> createState() => _ButtonControlsState();
// }

// class _ButtonControlsState extends State<ButtonControls> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<PlayerState>(
//                     stream: widget.player.playerStateStream,
//                     builder: (context, snapshot) {
//                       final playerState = snapshot.data;
//                       final processingState = playerState?.processingState;
//                       final playing = playerState?.playing;
//                       if (processingState == ProcessingState.loading ||
//                           processingState == ProcessingState.buffering) {
//                         return Container(
//                           margin: const EdgeInsets.all(9.0),
//                           width: 64.0,
//                           height: 64.0,
//                           child: const LoadingIndicator(),
//                         );
//                       } else if (playing != true) {
//                         return Container(
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.topRight,
//                               colors: [
//                                 Color(0xfffca311),
//                                 Color(0xff62DD69),
//                               ],
//                             ),
//                             border: Border.all(
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                               width: 1.0,
//                             ),
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: IconButton(
//                             icon: const Icon(Icons.play_arrow),
//                             iconSize: 64.0,
//                             onPressed: widget.player.play,
//                           ),
//                         );
//                       } else if (processingState != ProcessingState.completed) {
//                         return Container(
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.topRight,
//                               colors: [
//                                 Color(0xfffca311),
//                                 Color(0xff62DD69),
//                               ],
//                             ),
//                             border: Border.all(
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                               width: 1.0,
//                             ),
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: IconButton(
//                             icon: const Icon(Icons.pause),
//                             iconSize: 64.0,
//                             onPressed: widget.player.pause,
//                           ),
//                         );
//                       } else if (processingState == ProcessingState.completed) {
//                         playNext();
//                         return const LoadingIndicator();
//                       } else {
//                         BoxDecoration(
//                           gradient: const LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.topRight,
//                             colors: [
//                               Color(0xfffca311),
//                               Color(0xff62DD69),
//                             ],
//                           ),
//                           border: Border.all(
//                             color: const Color.fromARGB(255, 0, 0, 0),
//                             width: 1.0,
//                           ),
//                           borderRadius: BorderRadius.circular(50),
//                         );
//                         return IconButton(
//                           icon: const Icon(Icons.replay),
//                           iconSize: 64.0,
//                           onPressed: () => widget.player.seek(Duration.zero),
//                         );
//                       }
//                     },
//                   );
                  
//   }
// }