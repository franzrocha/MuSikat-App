import 'package:flutter/material.dart';
import 'package:musikat_app/controllers/recommender_controller.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'package:musikat_app/widgets/display_widgets.dart';

class RecommendedSongs extends StatelessWidget {
  final RecommenderController controller;
  final MusicHandler musicHandler;
  final String myUid;
  const RecommendedSongs({
    super.key,
    required this.controller,
    required this.musicHandler,
    required this.myUid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SongDisplay(
          songs: controller.recommendedSongs,
          onTap: (song) {
            musicHandler.currentSongs = controller.recommendedSongs;
            musicHandler.currentIndex =
                controller.recommendedSongsUidsList.indexOf(song);
            musicHandler.setAudioSource(
              controller
                  .recommendedSongs[controller.recommendedSongs.indexOf(song)],
              myUid,
            );
          },
          caption: 'Recommended Songs For You',
        ),
      ],
    );
  }
}
