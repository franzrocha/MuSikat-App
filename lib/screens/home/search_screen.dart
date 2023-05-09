import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/navigation/navigation_service.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import 'package:musikat_app/utils/exports.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textCon = TextEditingController();
  Future<List<SongModel>>? getSongs;
  Future<List<UserModel>>? getUsers;

  UserModel? user;

  @override
  Widget build(BuildContext context) {
    getSongs ??= SongModel.getSongs();
    getUsers ??= UserModel.getUsers();

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
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                hintStyle: GoogleFonts.inter(fontSize: 15, color: Colors.grey),
              ),
            ),
            showLogo: false),
        backgroundColor: musikatBackgroundColor,
        body: SizedBox(
          child: FutureBuilder<List<Object>>(
              future: Future.wait([
                getUsers as Future<Object>,
                getSongs as Future<Object>,
              ]),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Object>> snapshot,
              ) {
                if (!snapshot.hasData) {
                  return const Center(child: LoadingIndicator());
                }

                List<UserModel> userSearchResult = [];
                List<SongModel> songSearchResult = [];
                if (_textCon.text.isNotEmpty) {
                  for (var element in snapshot.data![0] as List<UserModel>) {
                    if (element.searchUsername(_textCon.text)) {
                      userSearchResult.add(element);
                    }
                  }

                  for (var element in snapshot.data![1] as List<SongModel>) {
                    if (element.searchTitle(_textCon.text)) {
                      songSearchResult.add(element);
                    }
                  }

                  bool isVowel(String letter, String searchLetter) {
                    String vowels = 'aeiou';
                    int vowelIndex = vowels.indexOf(letter);
                    int searchIndex = vowels.indexOf(searchLetter);
                    return vowelIndex >= 0 && vowelIndex < searchIndex;
                  }

                  List<Object> combinedResults = [];
                  combinedResults.addAll(userSearchResult);
                  combinedResults.addAll(songSearchResult);
                  String query = _textCon.text.toLowerCase();
                  String searchLetter =
                      query.isNotEmpty ? query.substring(0, 1) : '';
                  combinedResults.sort((a, b) {
                    int relevanceA = 0;
                    int relevanceB = 0;

                    if (a is UserModel) {
                      UserModel user = a;
                      String username = user.username.toLowerCase();
                      if (username.startsWith(searchLetter)) {
                        relevanceA += 2;
                      } else if (username.contains(searchLetter)) {
                        relevanceA += 1;
                      }
                      if (isVowel(username[0], searchLetter)) {
                        relevanceA += 1;
                      }
                      relevanceA += username.split(query).length - 1;
                    } else if (a is SongModel) {
                      SongModel song = a;
                      String title = song.title.toLowerCase();
                      if (title.startsWith(searchLetter)) {
                        relevanceA += 2;
                      } else if (title.contains(searchLetter)) {
                        relevanceA += 1;
                      }
                      if (isVowel(title[0], searchLetter)) {
                        relevanceA += 1;
                      }
                      relevanceA += title.split(query).length - 1;
                    }

                    if (b is UserModel) {
                      UserModel user = b;
                      String username = user.username.toLowerCase();
                      if (username.startsWith(searchLetter)) {
                        relevanceB += 2;
                      } else if (username.contains(searchLetter)) {
                        relevanceB += 1;
                      }
                      if (isVowel(username[0], searchLetter)) {
                        relevanceB += 1;
                      }
                      relevanceB += username.split(query).length - 1;
                    } else if (b is SongModel) {
                      SongModel song = b;
                      String title = song.title.toLowerCase();
                      if (title.startsWith(searchLetter)) {
                        relevanceB += 2;
                      } else if (title.contains(searchLetter)) {
                        relevanceB += 1;
                      }
                      if (isVowel(title[0], searchLetter)) {
                        relevanceB += 1;
                      }
                      relevanceB += title.split(query).length - 1;
                    }

                    return relevanceB.compareTo(relevanceA);
                  });

                  return combinedResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/no_results.png",
                                width: 130,
                                height: 130,
                              ),
                              const SizedBox(height: 30),
                              Text(
                                'No results found',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: combinedResults.length,
                          itemBuilder: (context, index) {
                            if (combinedResults[index] is UserModel) {
                              UserModel user =
                                  combinedResults[index] as UserModel;
                              return user.uid !=
                                      FirebaseAuth.instance.currentUser?.uid
                                  ? ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          FadeRoute(
                                            page: ArtistsProfileScreen(
                                              selectedUserUID: user.uid,
                                            ),
                                            settings: const RouteSettings(),
                                          ),
                                        );
                                      },
                                      leading: AvatarImage(uid: user.uid),
                                      title: Text(
                                        user.username,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'User',
                                        style: GoogleFonts.inter(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            } else if (combinedResults[index] is SongModel) {
                              SongModel song =
                                  combinedResults[index] as SongModel;
                              return song.uid !=
                                      FirebaseAuth.instance.currentUser?.uid
                                  ? ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          FadeRoute(
                                            page: MusicPlayerScreen(
                                              songs: songSearchResult
                                                  .where((s) =>
                                                      s.songId == song.songId)
                                                  .toList(),
                                            ),
                                            settings: const RouteSettings(),
                                          ),
                                        );
                                      },
                                      onLongPress: () {
                                        showModalBottomSheet(
                                            backgroundColor: musikatColor4,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return SingleChildScrollView(
                                                child: SongBottomField(
                                                  song: song,
                                                  hideEdit: true,
                                                  hideDelete: true,
                                                  hideRemoveToPlaylist: true,
                                                ),
                                              );
                                            });
                                      },
                                      title: Text(
                                        song.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(song.albumCover),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            song.artist,
                                            style: GoogleFonts.inter(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            ' • Song',
                                            style: GoogleFonts.inter(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontSize: 14,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : const SizedBox();
                            } else {
                              return const SizedBox();
                            }
                          },
                        );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/search.png",
                          width: 250,
                          height: 220,
                        ),
                        Text(
                          'Search for your favourite music or your friends',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}
