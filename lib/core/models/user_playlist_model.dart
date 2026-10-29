import 'song_model.dart';

class UserPlaylist {
  const UserPlaylist({required this.name, required this.songs, this.id});

  // The stored playlist's Hive key. Unlike the name it survives a rename, so
  // screens use it to keep following the same playlist.
  final Object? id;
  final String name;
  final List<Song> songs;

  static const _collageTiles = 4;

  // Seeds for the 2x2 collage: the first four song titles, or the playlist's
  // own name when it has no songs.
  List<String> get coverSeeds {
    if (songs.isEmpty) return [name];
    return [for (final song in songs.take(_collageTiles)) song.title];
  }
}
