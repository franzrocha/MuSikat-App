import 'package:flutter/material.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/utils/constants.dart';

import '../service_locators.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  //Lift MusicPlayer controller up, upto the common parent widget of both nav bar and music player (screen)
  //aron usa ra iyang controller, to which same ra ang ilang ma play nga music

  @override
  Widget build(BuildContext context) {
    final MusicHandler _musicHandler = locator<MusicHandler>();

    const double borderRadius = 10;
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
          ),
          color: Colors.red),
      margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03,
          vertical: MediaQuery.of(context).size.height * 0.005,
        ),
        child: Row(
          children: [
            //tuhmbnail
            Expanded(
                flex: 1,
                child: Container(
                    //   decoration: BoxDecoration(
                    //     color: musikatBackgroundColor,
                    //     border: Border.all(
                    //       color: const Color.fromARGB(255, 124, 131, 127),
                    //     ),
                    //     borderRadius: BorderRadius.circular(5),
                    //     image: DecorationImage(
                    //       image: NetworkImage(
                    //           _musicHandler[_musicHandler.currentIndex].albumCover),
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),

                    )),
            //Text
            const Expanded(
              flex: 5,
              child: Text('Now playing...'),
            ),
            //Button
            Expanded(
              child: ElevatedButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
