import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import 'package:musikat_app/utils/exports.dart';

class SongDisplay extends StatelessWidget {
  final String caption;
  final List<SongModel> songs;
  final Function(SongModel) onTap;

  const SongDisplay({
    super.key,
    required this.songs,
    required this.onTap,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 10),
            child: Container(
              padding: const EdgeInsets.only(top: 25),
              child: Text(
                caption,
                textAlign: TextAlign.right,
                style: sloganStyle,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: songs.map((song) {
              return Padding(
                padding: const EdgeInsets.only(left: 25, top: 10),
                child: GestureDetector(
                  onTap: () => onTap(song),
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
                            hideLike: false,
                          ),
                        );
                      },
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(song.albumCover),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        song.title.length > 19
                            ? '${song.title.substring(0, 19)}..'
                            : song.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: titleStyle,
                      ),
                      Text(
                        song.artist,
                        textAlign: TextAlign.left,
                        style: artistStyle,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ArtistDisplay extends StatelessWidget {
  final List<UserModel> users;
  final String caption;

  const ArtistDisplay({
    super.key,
    required this.users,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 10),
            child: Container(
              padding: const EdgeInsets.only(top: 25),
              child: Text(
                caption,
                textAlign: TextAlign.right,
                style: sloganStyle,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(

              children: users.map((user) {
                return Padding(
                  padding: const EdgeInsets.only(left: 25, top: 10),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ArtistsProfileScreen(
                                            selectedUserUID: user.uid,
                                          )));
                            },
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(100),
                                image: user.profileImage.isNotEmpty
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            user.profileImage),
                                        fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            userIcon),
                                        fit: BoxFit.cover,
                                      )
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              user.username,
                              style: titleStyle,
                            ),
                          ),
                            Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              '${user.followers.length} followers',
                              style: artistStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class PlaylistDisplay extends StatelessWidget {
  final String caption;
  final List<PlaylistModel> playlists;
  final Function(PlaylistModel) onTap;

  const PlaylistDisplay({
    super.key,
    required this.playlists,
    required this.onTap,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 10),
            child: Container(
              padding: const EdgeInsets.only(top: 25),
              child: Text(
                caption,
                textAlign: TextAlign.right,
                style: sloganStyle,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: playlists.map((playlist) {
              return Padding(
                padding: const EdgeInsets.only(left: 25, top: 10),
                child: GestureDetector(
                  onTap: () => onTap(playlist),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                playlist.playlistImg),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        playlist.title.length > 19
                            ? '${playlist.title.substring(0, 19)}..'
                            : playlist.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: titleStyle,
                      ),
                      Text(
                        (playlist.description != null &&
                                playlist.description!.length > 19)
                            ? '${playlist.description?.substring(0, 19)}..'
                            : playlist.description ?? '',
                        textAlign: TextAlign.left,
                        style: artistStyle,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
