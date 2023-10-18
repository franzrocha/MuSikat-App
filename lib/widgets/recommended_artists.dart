import 'package:flutter/material.dart';
import 'package:musikat_app/controllers/recommender_controller.dart';
import 'package:musikat_app/widgets/display_widgets.dart';

class RecommendedSearchArtists extends StatelessWidget {
  final RecommenderController controller;
  const RecommendedSearchArtists({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArtistDisplay(
          users: controller.recommendedArtists,
          caption: 'Recommended Artist For You',
        ),
      ],
    );
  }
}
