import 'library_store.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

class PlaylistRepository {
  PlaylistRepository(this._store);

  final LibraryStore _store;

  List<Playlist> load() => _store.playlists();

  Future<String?> create(String name, List<Song> songs) async {
    final error = validateName(name);
    if (error != null) return error;
    await _store.createPlaylist(name.trim(), songs);
    return null;
  }

  Future<String?> rename(String name, String newName) async {
    final error = validateName(newName, ignoring: name);
    if (error != null) return error;
    return _store.renamePlaylist(name, newName.trim());
  }

  Future<String?> saveSongs(String name, List<Song> songs) async {
    if (_store.playlists().every((playlist) => playlist.name != name)) {
      return 'Playlist not found';
    }
    await _store.replaceSongs(name, songs);
    return null;
  }

  Future<void> addSong(String playlistName, Song song) =>
      _store.addSong(playlistName, song);

  Future<void> removeSong(String playlistName, String path) =>
      _store.removeSong(playlistName, path);

  Future<void> delete(String name) => _store.deletePlaylist(name);

  String? validateName(String name, {String? ignoring}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Enter a playlist name';
    final taken = _store.playlists().any(
          (playlist) => playlist.name == trimmed && playlist.name != ignoring,
        );
    if (taken) return 'A playlist with this name already exists';
    return null;
  }
}
