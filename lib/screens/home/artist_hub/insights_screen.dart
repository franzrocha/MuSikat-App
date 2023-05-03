import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

class InsightsScreen extends StatefulWidget {
  static const String route = 'artists-screen';
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final SongsController _songCon = SongsController();

  UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Insights',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(children: [
            FutureBuilder<int>(
              future: _songCon.getUserSongCount(),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('Songs uploaded: ${snapshot.data}',
                      style: const TextStyle(color: Colors.white));
                }
              },
            ),
            ListTile(
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Song Plays',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white, size: 18),
              title: Text(
                'Likes',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const Divider(height: 20, indent: 1.0, color: listileColor),
            ListTile(
              title: Text(
                'Top Tracks',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.normal),
              ),
            ),
            const SizedBox(height: 150),
          ]),
        ),
      ),
    );
  }
}
