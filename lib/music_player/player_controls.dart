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


