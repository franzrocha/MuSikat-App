import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musikat_app/controllers/navigation/navigation_service.dart';
import 'package:musikat_app/models/recent_log_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/music_player/music_player.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import 'package:musikat_app/utils/exports.dart';

import '../../controllers/user_search_history_logs.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

//this code is to complicated to understand cuz you ned to know different between stateless and statefull widget and how to lifting up the state fron children to the parent
//Cuz without it you may get a problem for updating the value in the user interface

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textCon = TextEditingController();
  Future<List<SongModel>>? getSongs;
  Future<List<UserModel>>? getUsers;
  //this is the model set in  recent model section
  Future<List<RecentLogsModel>>? listRecentSearch;
  Future<int>? recentLogLength;

  // final SongsController _songCon = SongsController();

  UserModel? user;

  //state set
  bool isDeleted = false;
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    getSongs ??= SongModel.getSongs();
    getUsers ??= UserModel.getUsers();
    listRecentSearch ??= RecentHistoryUserSearchLogs().getHistoryLogs();
    recentLogLength ??= RecentHistoryUserSearchLogs().getLengthRecord();

    //delete recent specific user
    void getStateHandler(listRecentSearch, index, lengthValue) {
      setState(() {
        RecentHistoryUserSearchLogs()
            .deleteHistoryLogs(listRecentSearch[index].uid);
        // Remove the corresponding value from the array
        listRecentSearch.removeAt(index);
        Fluttertoast.showToast(
            msg: "Deleted record successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0);

        if (lengthValue == 1) {
          isDeleted = true;
        } else {
          counter = lengthValue - 1;
        }
      });
    }

    //this code used when you tap the list tile for the recent logs search
    void getStateTextInput(String value) {
      setState(() {
        _textCon.text = value;
      });
    }

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: textField(uid), showLogo: false),
        backgroundColor: musikatBackgroundColor,
        body: SizedBox(
          child: FutureBuilder<List<Object>>(
              future: Future.wait([
                getUsers as Future<Object>,
                getSongs as Future<Object>,
                recentLogLength as Future<int>
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

                //converted the number ro string to prevent null values error
                String lengthRecordLog = snapshot.data![2].toString();

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

                  if (combinedResults.isEmpty) {
                    return noResults();
                  } else {
                    return showResults(combinedResults, songSearchResult);
                  }
                } else {
                  //this code start the recent log search history logic that I told on upper part of this code
                  //the counter state default to the length record in the firebase store that we coded in user search history controller

                  if (counter == 0) {
                    counter = int.parse(lengthRecordLog);
                  }

                  if (counter > 0 && isDeleted == false) {
                    return recentHistory(
                        listRecentSearch as Future<List<RecentLogsModel>>,
                        getStateHandler,
                        getStateTextInput,
                        counter);
                  } else {
                    return noSearchYet();
                  }
                }
              }),
        ),
      ),
    );
  }

  //this code for ui of tile list in recent log search history
  //to understand this code you need to understand how markup this language works like how column and rows
  //We use Future builder cus We define our state as asynchronous method that why Future builder used instead list builder
  //ListView handled scrollable effect that why we use listview instead card or column
  //this code is generated  list of our item that define in the getHistoryLogs in user search history logs controller

  FutureBuilder<List<RecentLogsModel>> recentHistory(
      Future<List<RecentLogsModel>> listRecentSearch,
      getStateHandler,
      getStateTextInput,
      counter) {
    return FutureBuilder<List<RecentLogsModel>>(
      future: listRecentSearch,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return noSearchYet();
        } else {
          List<RecentLogsModel> listRecentSearch = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Recent List',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listRecentSearch.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        //callback for getting new search input
                        getStateTextInput(listRecentSearch[index].recentList);
                      },
                      // leading: CircleAvatar(
                      //   backgroundColor: Colors.blue,
                      //   maxRadius: 30,
                      //   child: NetworkImage(listRecentSearch[index].uploadedPhoto),
                      // ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                listRecentSearch[index].uploadedPhoto),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        listRecentSearch[index].recentList,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        listRecentSearch[index].type,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          //callback for deleting record
                          getStateHandler(listRecentSearch, index, counter);
                        },
                        child: Text(
                          'X',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Center noSearchYet() {
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
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  ListView showResults(
      List<Object> combinedResults, List<SongModel> songSearchResult) {
    return ListView.builder(
      itemCount: combinedResults.length,
      itemBuilder: (context, index) {
        if (combinedResults[index] is UserModel) {
          UserModel user = combinedResults[index] as UserModel;
          return user.uid != FirebaseAuth.instance.currentUser?.uid
              ? ListTile(
                  onTap: () {
                    RecentHistoryUserSearchLogs().addSearchHistoryLogs(
                        user.uid, user.username, user.profileImage, 'User');

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
          SongModel song = combinedResults[index] as SongModel;
          return song.uid != FirebaseAuth.instance.currentUser?.uid
              ? ListTile(
                  onTap: () {
                    RecentHistoryUserSearchLogs().addSearchHistoryLogs(
                        song.songId,
                        song.title,
                        song.albumCover,
                        '${song.artist} • Song');
                    Navigator.of(context).push(
                      FadeRoute(
                        page: MusicPlayerScreen(
                          songs: songSearchResult
                              .where((s) => s.songId == song.songId)
                              .toList(),
                          recommendedSongs: [],
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
                        image: NetworkImage(song.albumCover),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        song.artist,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' • Song',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
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
  }

  Center noResults() {
    return Center(
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
    );
  }

  TextField textField(String uid) {
    return TextField(
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
    );
  }
}
