import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:musikat_app/models/recommended_artist_model.dart';
import 'package:musikat_app/models/recommended_songs.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';

class RecommenderController extends GetxController {
  final String myUid;
  RecommenderController({required this.myUid});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns lists of usersId from recommendedArtists collection
  final RxList<String> recommendedUsersUidsList = RxList<String>([]);

  /// Returns lists of recommendedArtists from users collection
  final RxList<UserModel> recommendedArtists = RxList<UserModel>([]);

  /// Returns list of recommended songs uids based from recommendedSongs collection
  final RxList<String> recommendedSongsUidsList = RxList<String>([]);

  /// Returns lists of recommendedSongs from songs collection
  final RxList<SongModel> recommendedSongs = RxList<SongModel>([]);

  static RecommenderController get instance =>
      Get.find<RecommenderController>();

  @override
  void dispose() {
    recommendedUsersUidsList.close();
    recommendedArtists.close();
    recommendedSongsUidsList.close();
    recommendedSongs.close();
    super.dispose();
  }

  void fetchRecommendedArtists(String myUid) async {
    final recommendedArtistsDoc =
        await _db.collection('recommendedArtists').doc(myUid).get();
    if (recommendedArtistsDoc.exists) {
      final artistsData =
          RecommendedArtist.fromJson(recommendedArtistsDoc.data()!);

      // Limit num of artists to 5 maximum
      int numOfArtistData =
          artistsData.usersId.length < 5 ? artistsData.usersId.length : 5;
      recommendedUsersUidsList.value =
          artistsData.usersId.sublist(0, numOfArtistData);

      List<UserModel> users = [];
      if (recommendedUsersUidsList.value.isNotEmpty) {
        // Queries the users that matches the uids from RecommendedArtists collection
        final usersQueryResults = await _db
            .collection('users')
            .where('uid', whereIn: recommendedUsersUidsList.value)
            .get();
        if (usersQueryResults.docs.isNotEmpty) {
          users = usersQueryResults.docs
              .map((doc) => UserModel.fromDocumentSnap(doc))
              .toList();

          // Sorts to match the order of uids based from RecommendedArtists collection
          if (users.isNotEmpty) {
            users.sort((a, b) {
              final indexA = recommendedUsersUidsList.value.indexOf(a.uid);
              final indexB = recommendedUsersUidsList.value.indexOf(b.uid);
              return indexA.compareTo(indexB);
            });
            recommendedArtists.value = users;
          }

          update();
        }
      }
    }
  }

  void fetchRecommendedSongs(String myUid) async {
    final recommendedSongsDoc =
        await _db.collection('recommendedSongs').doc(myUid).get();
    if (recommendedSongsDoc.exists) {
      final songsData =
          RecommendedSongsModel.fromJson(recommendedSongsDoc.data()!);

      // Limit num of songs to 5 maximum
      int numOfSongsData =
          songsData.songId.length < 5 ? songsData.songId.length : 5;
      recommendedSongsUidsList.value =
          songsData.songId.sublist(0, numOfSongsData);

      List<SongModel> songs = [];
      if (recommendedSongsUidsList.value.isNotEmpty) {
        // Queries the song that matches the songId from RecommendedSongs collection
        final songsQueryResults = await _db
            .collection('songs')
            .where('song_id', whereIn: recommendedSongsUidsList.value)
            .get();
        if (songsQueryResults.docs.isNotEmpty) {
          songs = songsQueryResults.docs
              .map((doc) => SongModel.fromDocumentSnap(doc))
              .toList();

          if (songs.isNotEmpty) {
            // Sorts to match the order of uids based from RecommendedArtists collection
            songs.sort((a, b) {
              final indexA = recommendedSongsUidsList.value.indexOf(a.songId);
              final indexB = recommendedSongsUidsList.value.indexOf(b.songId);
              return indexA.compareTo(indexB);
            });
            recommendedSongs.value = songs;
          }

          update();
        }
      }
    }
  }

  void addRecommendedSongs(
      {String userId = '', String currentSongId = ''}) async {
    final songsCollection =
        await _db.collection('songs').where('uid', isEqualTo: userId).get();
    List<String> recommendedSongsId = [];

    if (songsCollection.docs.isNotEmpty) {
      List<SongModel> songsFromSongsCollection = songsCollection.docs
          .map((doc) => SongModel.fromDocumentSnap(doc))
          .toList()
        ..shuffle();

      final recommendedSongsDoc =
          await _db.collection('recommendedSongs').doc(myUid).get();
      if (recommendedSongsDoc.exists) {
        final recommendedSongData =
            RecommendedSongsModel.fromJson(recommendedSongsDoc.data()!);
        recommendedSongsId = recommendedSongData.songId;
        String randomSongId = '';
        for (var song in songsFromSongsCollection) {
          if (!recommendedSongsId.contains(song.songId) &&
              song.songId != currentSongId) {
            randomSongId = song.songId;
            recommendedSongsId.insert(0, randomSongId);
            break;
          }
        }

        if (randomSongId.isNotEmpty) {
          _db.collection('recommendedSongs').doc(myUid).set(
            {
              'uid': myUid,
              'songId': recommendedSongsId,
            },
            SetOptions(merge: true),
          );
        }
      } else {
        for (var song in songsFromSongsCollection) {
          if (song.songId != currentSongId) {
            _db.collection('recommendedSongs').doc(myUid).set(
              {
                'uid': myUid,
                'songId': [song.songId],
              },
              SetOptions(merge: true),
            );
            break;
          }
        }
      }
    }
  }

  void addRecommendArtist({String userUid = ''}) async {
    _db.collection('users').doc(userUid).get().then((usersDoc) {
      final userData = UserModel.fromDocumentSnap(usersDoc);
      List<String> recommendedUserIdsFollowers = [];

      if (userData.followers.isNotEmpty) {
        // RandomFollowersUids is followers from users collection
        List<String> randomFollowersUids = List<String>.from(userData.followers)
          ..shuffle();
        _db
            .collection('recommendedArtists')
            .doc(myUid)
            .get()
            .then((recommendedArtistDoc) {
          if (recommendedArtistDoc.exists) {
            final recommendedUser =
                RecommendedArtist.fromJson(recommendedArtistDoc.data()!);

            // recommendedUserIdsFollowers is usersId from RecommendedArtists collection
            recommendedUserIdsFollowers = recommendedUser.usersId;
          }
          String randomUserId = '';
          for (String userId in randomFollowersUids) {
            if (!recommendedUserIdsFollowers.contains(userId)) {
              // Inserts the new userId on first index of the list
              // break afterwards, to make sure only 1 is added per situation.
              randomUserId = userId;
              recommendedUserIdsFollowers.insert(0, randomUserId);
              break;
            }
          }
          if (randomUserId.isNotEmpty) {
            _db.collection('recommendedArtists').doc(myUid).set(
              {
                'uid': myUid,
                'usersId':
                    recommendedUserIdsFollowers, // Sets the newly updated list of usersUid to db.
              },
              SetOptions(merge: true),
            );
          }
        });
      }
    });
  }
}
