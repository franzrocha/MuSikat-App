import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/widgets/song_bottom_field.dart';

class SongDisplay extends StatelessWidget {
  final String slogan;
  final List<SongModel> songs;
  final Function(SongModel) onTap;

  const SongDisplay({
    super.key,
    required this.songs,
    required this.onTap,
    required this.slogan,
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
                slogan,
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
  final String slogan;

  const ArtistDisplay({
    super.key,
    required this.users,
    required this.slogan,
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
                slogan,
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
                                    : null,
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
