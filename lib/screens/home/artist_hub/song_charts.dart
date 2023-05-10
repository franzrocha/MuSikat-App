import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/utils/exports.dart';

class SongPlayCountChart extends StatefulWidget {
  final List<SongModel> songs;

  const SongPlayCountChart({super.key, required this.songs});

  @override
  // ignore: library_private_types_in_public_api
  _SongPlayCountChartState createState() => _SongPlayCountChartState();
}

class _SongPlayCountChartState extends State<SongPlayCountChart> {
  late List<SongPlayCount> songPlayCounts;
  late List<LikePlayCount> likePlayCounts;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    songPlayCounts = generateData(widget.songs);
    likePlayCounts = generateLikeData(widget.songs);
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(context),
        backgroundColor: musikatBackgroundColor,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    'Songs Chart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 5, 30, 100),
                  child: SfCartesianChart(
                    tooltipBehavior: _tooltipBehavior,
                    primaryXAxis: CategoryAxis(),
                    series: <ChartSeries>[
                      ColumnSeries<SongPlayCount, String>(
                        dataSource: songPlayCounts,
                        xValueMapper: (SongPlayCount songs, _) => songs.title,
                        yValueMapper: (SongPlayCount songs, _) =>
                            songs.playCount,
                        color: musikatColor,
                        name: 'Play Count',
                      ),
                    ],
                    selectionType: SelectionType.point,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    'Like Chart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 5, 30, 100),
                  child: SfCartesianChart(
                    tooltipBehavior: _tooltipBehavior,
                    primaryXAxis: CategoryAxis(),
                    series: <ChartSeries>[
                      ColumnSeries<LikePlayCount, String>(
                        dataSource: likePlayCounts,
                        xValueMapper: (LikePlayCount songs, _) => songs.title,
                        yValueMapper: (LikePlayCount songs, _) =>
                            songs.likeCount,
                        color: musikatColor,
                        name: 'Like Count',
                      ),
                    ],
                    selectionType: SelectionType.point,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      centerTitle: true,
      title: Text("",
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const FaIcon(
          FontAwesomeIcons.angleLeft,
          size: 20,
        ),
      ),
    );
  }
}

class SongPlayCount {
  final String title;
  final int playCount;

  SongPlayCount({required this.title, required this.playCount});
}

class LikePlayCount {
  final String title;
  final int likeCount;

  LikePlayCount({required this.title, required this.likeCount});
}

List<SongPlayCount> generateData(List<SongModel> songs) {
  List<SongPlayCount> songPlayCounts = [];

  // Group the songs by title
  Map<String, List<SongModel>> songsByTitle = groupSongsByTitle(songs);

  // Calculate the total play count for each title
  songsByTitle.forEach((key, value) {
    int totalPlayCount = 0;
    for (var song in value) {
      totalPlayCount += song.playCount;
    }
    songPlayCounts.add(SongPlayCount(title: key, playCount: totalPlayCount));
  });

  return songPlayCounts;
}

Map<String, List<SongModel>> groupSongsByTitle(List<SongModel> songs) {
  Map<String, List<SongModel>> songsByTitle = {};
  for (var song in songs) {
    if (songsByTitle.containsKey(song.title)) {
      songsByTitle[song.title]?.add(song);
    } else {
      songsByTitle[song.title] = [song];
    }
  }
  return songsByTitle;
}

List<LikePlayCount> generateLikeData(List<SongModel> songs) {
  List<LikePlayCount> likePlayCounts = [];

  // Group the songs by title
  Map<String, List<SongModel>> songsByTitle = groupSongsByTitle(songs);

  // Calculate the total play count for each title
  songsByTitle.forEach((key, value) {
    int totalLikeCount = 0;
    for (var song in value) {
      totalLikeCount += song.likeCount;
    }
    likePlayCounts.add(LikePlayCount(title: key, likeCount: totalLikeCount));
  });

  return likePlayCounts;
}
