// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/controllers/playlist_controller.dart';
import 'package:musikat_app/controllers/songs_controller.dart';
import 'package:musikat_app/models/playlist_model.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/utils/exports.dart';

class AddToPlaylistScreen extends StatefulWidget {
  const AddToPlaylistScreen({Key? key, required this.playlist})
      : super(key: key);
  final PlaylistModel playlist;

  @override
  State<AddToPlaylistScreen> createState() => _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends State<AddToPlaylistScreen> {
  final SongsController _songCon = SongsController();
  final PlaylistController _playCon = PlaylistController();
  TextEditingController searchController = TextEditingController();
  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _subscribeToSongs();
  }

  void _subscribeToSongs() {
    _songCon.getSongsStream().listen((List<SongModel>? songs) {
      if (songs != null) {
        setState(() {
          _songs = songs;
          _filteredSongs = songs;
        });
      }
    }, onError: (error) {});
  }

  @override
  void dispose() {
    _songCon.dispose();
    super.dispose();
  }

  void _filterSongs(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredSongs = _songs;
      } else {
        _filteredSongs = _songs.where((song) {
          final title = song.title.toLowerCase();
          final artist = song.artist.toLowerCase();
          final searchLower = searchTerm.toLowerCase();
          return title.contains(searchLower) || artist.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Add to playlist',
          style: appBarStyle,
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: Column(
        children: [
          SizedBox(
            height: 80,
            width: 400,
            child: TextField(
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              controller: searchController,
              onChanged: _filterSongs,
              decoration: InputDecoration(
                hintText: 'Search',
                fillColor: Colors.transparent,
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: 13,
                ),
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSongs.length,
              itemBuilder: (context, index) {
                final song = _filteredSongs[index];

                return ListTile(
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: songTitle,
                  ),
                  subtitle: Text(song.artist, style: songArtist),
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
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.grey,
                    ),
                    onPressed: () async {
                      try {
                        await _playCon.addSongToPlaylist(
                            widget.playlist.playlistId, song.songId);
                        ToastMessage.show(context, 'Song added to playlist');
                      } catch (e) {
                        ToastMessage.show(
                            context, 'Failed to add song to playlist');
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
