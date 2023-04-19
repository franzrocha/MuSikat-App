import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/screens/home/music_player.dart';
import 'package:musikat_app/utils/ui_exports.dart';
import 'package:musikat_app/utils/widgets_export.dart';

class SongSearchScreen extends StatefulWidget {
  const SongSearchScreen({Key? key}) : super(key: key);

  @override
  State<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends State<SongSearchScreen> {
  final TextEditingController _textCon = TextEditingController();
  Future<List<SongModel>>? getSongs;

  @override
  void dispose() {
    _textCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getSongs ??= SongModel.getSongs();

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
            title: TextField(
              autofocus: true,
              controller: _textCon,
              onSubmitted: (textCon) {},
              onChanged: (text) {
                setState(() {});
              },
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            showLogo: false),
        backgroundColor: musikatBackgroundColor,
        body: SizedBox(
          child: FutureBuilder<List<SongModel>>(
              future: getSongs,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<SongModel>> snapshot,
              ) {
                if (!snapshot.hasData) {
                  return const Center(child: LoadingIndicator());
                }

                List<SongModel> searchResult = [];
                if (_textCon.text.isNotEmpty) {
                  for (var element in snapshot.data!) {
                    if (element.searchTitle(_textCon.text)) {
                      searchResult.add(element);
                    }
                  }

                  return searchResult.isEmpty
                      ? Center(
                          child: Text('No results found',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        )
                      : ListView.builder(
                          itemCount: searchResult.length,
                          itemBuilder: (context, index) {
                            return searchResult[index].uid !=
                                    FirebaseAuth.instance.currentUser?.uid
                                ? ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MusicPlayerScreen(
                                                  songs: searchResult
                                                      .where((song) =>
                                                          song.songId ==
                                                          searchResult[index]
                                                              .songId)
                                                      .toList(),
                                                  username:
                                                      searchResult[index].uid,
                                                )),
                                      );
                                    },
                                    title: Text(
                                      searchResult[index].title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              searchResult[index].albumCover),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(searchResult[index].uid,
                                        style: GoogleFonts.inter(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontSize: 14)),
                                  )
                                : const SizedBox();
                          });
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 150),
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/search.png",
                          width: 254,
                          height: 254,
                        ),
                        Text('Search for your favourite music or your friends',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
