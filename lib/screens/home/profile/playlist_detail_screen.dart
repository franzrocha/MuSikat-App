import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/utils/exports.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});

  final PlaylistModel playlist;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomSliverBar(
            image: widget.playlist.playlistImg,
            title: widget.playlist.title,
            caption: widget.playlist.description,
          ),
          SliverFillRemaining(),
        ],
      ),
    );
  }
}
