import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/artist_hub/song_charts.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar(context),
        backgroundColor: musikatBackgroundColor,
        body: SafeArea(
          child: TabBarView(
            children: [
              overviewTab(),
              tracksTab(),
            ],
          ),
        ),
      ),
    );
  }

  Column tracksTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder<int>(
          future: _songCon.getUserSongCount(),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListTile(
                title: Row(
                  children: [
                    Text('Total Tracks:', style: shortDefault),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('${snapshot.data}', style: shortDefault),
                  ],
                ),
              );
            }
          },
        ),
        Expanded(
          child: StreamBuilder<List<SongModel>>(
            stream: _songCon.getSongsStream(),
            builder: (BuildContext context,
                AsyncSnapshot<List<SongModel>> snapshot) {
              if (snapshot.hasData) {
                final List<SongModel> songs = snapshot.data!
                    .where((song) =>
                        song.uid == FirebaseAuth.instance.currentUser?.uid)
                    .toList();

                return ListView.separated(
                  itemCount: songs.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final SongModel song = songs[index];
                    return ListTile(
                      // onTap: () {
                      //   // Handle song tap
                      // },
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(song.albumCover),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: songTitle,
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.play,
                            color: musikatColor2,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            song.playCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 20),
                          const FaIcon(
                            FontAwesomeIcons.solidHeart,
                            color: Colors.red,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            song.likeCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return const Center(
                  child: LoadingIndicator(),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Column overviewTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            'Top Tracks',
            style: sloganStyle,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: FutureBuilder(
            future: _songCon.getRankedSongs(),
            builder: (BuildContext context,
                AsyncSnapshot<List<SongModel>> snapshot) {
              if (snapshot.hasData) {
                final List<SongModel> songs = snapshot.data!
                    .where((song) =>
                        song.uid == FirebaseAuth.instance.currentUser?.uid)
                    .toList();

                if (songs.isEmpty) {
                  return Center(
                    child: Text('No songs found in your library.', style: shortThinStyle,),
                  );
                }

                return ListView.separated(
                  itemCount: songs.length > 5 ? 5 : songs.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final SongModel song = songs[index];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                SongPlayCountChart(songs: songs),
                          ),
                        );
                      },
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(song.albumCover),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        '${index + 1}.  ${song.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: songTitle,
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return const Center(
                  child: LoadingIndicator(),
                );
              }
            },
          ),
        ),
        Expanded(
            child: FutureBuilder<int>(
          future:
              _songCon.getOverallPlays(FirebaseAuth.instance.currentUser!.uid),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListTile(
                title: Row(
                  children: [
                    Text('Overall Streams:', style: sloganStyle),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('${snapshot.data}', style: sloganStyle),
                  ],
                ),
              );
            }
          },
        ))
      ],
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Insights',
        style: appBarStyle,
      ),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const FaIcon(FontAwesomeIcons.angleLeft, size: 20)),
      automaticallyImplyLeading: false,
      bottom: TabBar(
        labelStyle: shortDefault,
        labelColor: Colors.white,
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: musikatColor,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Tracks'),
        ],
      ),
      backgroundColor: musikatBackgroundColor,
    );
  }
}
