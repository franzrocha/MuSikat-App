// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/listening_history_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/utils/exports.dart';

class ListeningHistoryScreen extends StatefulWidget {
  const ListeningHistoryScreen({super.key});

  @override
  State<ListeningHistoryScreen> createState() => _ListeningHistoryScreenState();
}

class _ListeningHistoryScreenState extends State<ListeningHistoryScreen> {
  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  final ListeningHistoryController _listenCon = ListeningHistoryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        showLogo: false,
        title: Text(
          'Listening History',
          style: appBarStyle,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await _listenCon.deleteListeningHistory(currentUser);
                ToastMessage.show(
                    context, 'Listening history deleted successfully.');
              } catch (error) {
                ToastMessage.show(context, 'Error: $error');
              }
            },
            icon: const FaIcon(
              FontAwesomeIcons.trash,
              size: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<SongModel>>(
            stream: _listenCon.getListeningHistoryStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: LoadingIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: LoadingIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<SongModel> recentlyPlayed = snapshot.data!.toList();

                return recentlyPlayed.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 70),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25),
                                child: Image.asset(
                                    "assets/images/no_played.png",
                                    width: 230,
                                    height: 230),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No played songs yet.",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    height: 2,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: recentlyPlayed.length,
                        itemBuilder: (context, index) {
                          SongModel songData = recentlyPlayed[index];
                          return ListTile(
                            onLongPress: () {
                              showModalBottomSheet(
                                backgroundColor: musikatColor4,
                                context: context,
                                builder: (BuildContext context) {
                                  return SingleChildScrollView(
                                    child: SongBottomField(
                                      song: recentlyPlayed[index],
                                      hideEdit: true,
                                      hideDelete: true,
                                      hideRemoveToPlaylist: true,
                                      hideLike: false,
                                    ),
                                  );
                                },
                              );
                            },
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MusicPlayerScreen(
                                    songs: recentlyPlayed,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            title: Text(
                              songData.title,
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.white),
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              songData.artist,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      songData.albumCover),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      );
              }
            }),
      ),
    );
  }
}
