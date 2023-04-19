import 'package:musikat_app/utils/ui_exports.dart';
import 'package:musikat_app/utils/widgets_export.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: Text(
            'Playlists',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          showLogo: false,
        ),
      backgroundColor: musikatBackgroundColor,
    );
  }

}
