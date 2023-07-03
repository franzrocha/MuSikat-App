import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FutureBuilder<int>(
                future: _songCon
                    .getOverallPlays(FirebaseAuth.instance.currentUser!.uid),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final NumberFormat numberFormat = NumberFormat('#,###');
                    final formattedStreams = numberFormat.format(snapshot.data);

                    return Row(
                      children: [
                        Text('Overall Streams:', style: shortDefault),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(formattedStreams, style: shortDefault),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(width: 40),
              FutureBuilder<int>(
                future: _songCon
                    .getOverallLikes(FirebaseAuth.instance.currentUser!.uid),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final NumberFormat numberFormat = NumberFormat('#,###');
                    final formattedStreams = numberFormat.format(snapshot.data);

                    return Row(
                      children: [
                        Text('Overall Likes:', style: shortDefault),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(formattedStreams, style: shortDefault),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
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
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.play,
                            color: musikatColor2,
                            size: 15,
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 50,
                            child: Text(
                              _formatNumber(song.playCount),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const FaIcon(
                            FontAwesomeIcons.solidHeart,
                            color: Colors.red,
                            size: 15,
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 50,
                            child: Text(
                              _formatNumber(song.likeCount),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const Icon(
                            Icons.playlist_play,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: 50,
                              child: FutureBuilder(
                                  future: _songCon.getPlaylistAdds(song.songId),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<int> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container();
                                    } else {
                                      return Text(
                                        snapshot.data.toString(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      );
                                    }
                                  }))
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

  SingleChildScrollView overviewTab() {
    return SingleChildScrollView(
      child: Column(
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
          SizedBox(
            height: 320,
            child: FutureBuilder(
              future: _songCon
                  .getRankedSongs(FirebaseAuth.instance.currentUser!.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<List<SongModel>> snapshot) {
                if (snapshot.hasData) {
                  final List<SongModel> songs = snapshot.data!;
                  if (songs.isEmpty) {
                    return Center(
                      child: Text(
                        'No songs found in your library.',
                        style: shortThinStyle,
                      ),
                    );
                  }


                    
                  return ListView.separated(
                    itemCount: songs.length > 5 ? 5 : songs.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final SongModel song = songs[index];
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  CachedNetworkImageProvider(song.albumCover),
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: FutureBuilder<List<SongModel>>(
              future: _songCon
                  .getRankedSongs(FirebaseAuth.instance.currentUser!.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<List<SongModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  );
                } else {
                  final List<SongModel> songs = snapshot.data!.take(5).toList();

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 56, 54, 54),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelStyle: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                        maximumLabelWidth: 70,
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      series: <ChartSeries>[
                        ColumnSeries<SongModel, String>(
                          dataSource: songs,
                          xValueMapper: (SongModel song, _) => song.title,
                          yValueMapper: (SongModel song, _) =>
                              song.playCount + song.likeCount,
                          color: musikatColor3,
                        ),
                      ],
                      title: ChartTitle(
                        text: 'Top Tracks Stats',
                        textStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      legend: Legend(isVisible: false),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        header: '',
                        format: 'point.x: point.y',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
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

  String _formatNumber(int number) {
    if (number >= 1000) {
      final String formattedNumber = NumberFormat.compact().format(number);
      return formattedNumber;
    } else {
      return number.toString();
    }
  }
}
