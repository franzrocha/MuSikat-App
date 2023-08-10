// ignore_for_file: unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/listening_history_controller.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/models/liked_songs_model.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';
import '../../music_player/music_handler.dart';
import 'song_streams/songs_list.dart';

class HomeScreen extends StatefulWidget {
  final MusicHandler musicHandler;
  static const String route = 'home-screen';

  const HomeScreen({
    Key? key,
    required this.musicHandler,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SongsController _songCon = SongsController();
  final PlaylistController _playCon = PlaylistController();
  final ListeningHistoryController _listenCon = ListeningHistoryController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SingleChildScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 5),
            homeForOPM(),
            pinoyPride(),
            newReleases(),
            newPlaylist(),
            editorsPlaylists(),
            suggestedUsers(),
            popularTracks(),
            basedOnLikedSongs(),
            artiststToLookOut(),
            recentListening(),
            recommendedPlaylistsGenre(),
            basedOnListeningHistory(),
            basedOnListeningHistoryLanguage(),
            basedOnListeningHistoryMoods(),
            suggestedSongFromFollower(),
            const SizedBox(height: 120),
          ]),
        ),
      ),
    );
  }

  HomeForOPMStreamBuilder homeForOPM() {
    return HomeForOPMStreamBuilder(
        songStream: _songCon.getSongsStream(),
        musicHandler: widget.musicHandler,
        currentUserUid: uid,
        caption: 'Home for OPM');
  }

  PinoyPrideStreamBuilder pinoyPride() {
    return PinoyPrideStreamBuilder(
      playlistStream: _playCon.getPlaylistStream(),
      genreFilter: 'Random',
      caption: 'Pinoy Pride 🔥',
    );
  }

  NewReleasesStreamBuilder newReleases() {
    return NewReleasesStreamBuilder(
        songStream: _songCon.getSongsStream(),
        musicHandler: widget.musicHandler,
        currentUserUid: uid,
        caption: 'What\'s new?');
  }

  NewlyAddedPlaylistStreamBuilder newPlaylist() {
    return NewlyAddedPlaylistStreamBuilder(
      playlistStream: _playCon.getPlaylistStream(),
      caption: 'Newly posted playlist',
    );
  }

  EditorsPlaylistsStreamBuilder editorsPlaylists() {
    return EditorsPlaylistsStreamBuilder(
      playlistStream: _playCon.getPlaylistStream(),
      caption: 'Editor\'s Playlists',
    );
  }

  SuggestedUsersStreamBuilder suggestedUsers() {
    return SuggestedUsersStreamBuilder(
      userStream:
          UserModel.getNonFollowers(FirebaseAuth.instance.currentUser!.uid)
              .asStream(),
      currentUserUid: FirebaseAuth.instance.currentUser!.uid,
      caption: 'Suggested Users',
    );
  }

  PopularTracksStreamBuilder popularTracks() {
    return PopularTracksStreamBuilder(
        songStream: _songCon.getSongsStream(),
        musicHandler: widget.musicHandler,
        currentUserUid: uid,
        caption: 'Popular Tracks');
  }

  BasedOnListeningHistoryLanguageStreamBuilder basedOnLikedSongs() {
    return BasedOnListeningHistoryLanguageStreamBuilder(
      songStream: LikedSongsModel.getRecommendedSongsByLike().asStream(),
      currentUserUid: FirebaseAuth.instance.currentUser!.uid,
      musicHandler: widget.musicHandler,
      caption: 'More on what you like...',
    );
  }

  ArtistsToLookOutStreamBuilder artiststToLookOut() {
    return ArtistsToLookOutStreamBuilder(
        userStream: _songCon.getUsersWithSongs().asStream(),
        currentUserUid: FirebaseAuth.instance.currentUser!.uid,
        caption: 'Artists to look out for');
  }

  RecentListeningFutureBuilder recentListening() {
    return RecentListeningFutureBuilder(
        futureListeningHistory: _listenCon.getListeningHistory(),
        musicHandler: widget.musicHandler,
        currentUserUid: uid,
        caption: 'Recently played songs');
  }

  RecommendedPlaylistsGenreStreamBuilder recommendedPlaylistsGenre() {
    return RecommendedPlaylistsGenreStreamBuilder(
      playlistStream:
          _listenCon.getRecommendedPlaylistBasedOnGenre().asStream(),
      caption: 'Playlist recommendation',
    );
  }

  BasedOnListeningHistoryStreamBuilder basedOnListeningHistory() {
    return BasedOnListeningHistoryStreamBuilder(
        songStream: _listenCon.getRecommendedSongsBasedOnGenre().asStream(),
        musicHandler: widget.musicHandler,
        currentUserUid: FirebaseAuth.instance.currentUser!.uid,
        caption: 'Recommended based on genre');
  }

  BasedOnListeningHistoryLanguageStreamBuilder
      basedOnListeningHistoryLanguage() {
    return BasedOnListeningHistoryLanguageStreamBuilder(
      songStream: _listenCon.getRecommendedSongsBasedOnLanguage().asStream(),
      currentUserUid: FirebaseAuth.instance.currentUser!.uid,
      musicHandler: widget.musicHandler,
      caption: 'Recommended based on language',
    );
  }

  BasedOnListeningHistoryMoodsStreamBuilder basedOnListeningHistoryMoods() {
    return BasedOnListeningHistoryMoodsStreamBuilder(
      songStream: _listenCon.getRecommendedSongsBasedOnMoods().asStream(),
      currentUserUid: FirebaseAuth.instance.currentUser!.uid,
      musicHandler: widget.musicHandler,
      caption: 'Recommended based on moods',
    );
  }

  SuggestedSongFromFollowerStreamBuilder suggestedSongFromFollower() {
    return SuggestedSongFromFollowerStreamBuilder(
        uid: uid, musicHandler: widget.musicHandler);
  }
}
