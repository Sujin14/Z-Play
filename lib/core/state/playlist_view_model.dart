import 'package:flutter/foundation.dart';

import '../models/song_model.dart';
import '../data/playlist_repository.dart';
import 'library_view_model.dart';
import '../models/user_playlist_model.dart';

class PlaylistViewModel extends ChangeNotifier {
  PlaylistViewModel({
    required PlaylistRepository repository,
    required LibraryViewModel library,
  })  : _repository = repository,
        _library = library;

  final PlaylistRepository _repository;
  final LibraryViewModel _library;
  List<UserPlaylist> playlists = const [];

  void load() {
    playlists = [
      for (final playlist in _repository.load())
        UserPlaylist(
          id: playlist.key,
          name: playlist.name,
          songs: [
            for (final file in playlist.songs)
              _library.findByPath(file.path) ??
                  Song(path: file.path, title: file.title),
          ],
        ),
    ];
    notifyListeners();
  }

  String? validateName(String name, {String? ignoring}) {
    return _repository.validateName(name, ignoring: ignoring);
  }

  Future<String?> create(String name, List<Song> songs) async {
    final error = await _repository.create(name, songs);
    if (error == null) load();
    return error;
  }

  Future<String?> update({
    required String originalName,
    required String name,
    required List<Song> songs,
  }) async {
    var target = originalName;
    if (name.trim() != originalName) {
      final error = await _repository.rename(originalName, name);
      if (error != null) return error;
      target = name.trim();
    }
    final error = await _repository.saveSongs(target, songs);
    if (error == null) load();
    return error;
  }

  Future<String?> addSong(String name, Song song) async {
    final playlist = _named(name);
    if (playlist != null &&
        playlist.songs.any((item) => item.path == song.path)) {
      return '${_short(song.title)} is already in "$name"';
    }
    await _repository.addSong(name, song);
    load();
    return null;
  }

  Future<void> removeSong(String name, Song song) async {
    await _repository.removeSong(name, song.path);
    load();
  }

  Future<void> delete(String name) async {
    await _repository.delete(name);
    load();
  }

  // Survives renames, unlike looking a playlist up by name.
  UserPlaylist? byId(Object id) {
    for (final playlist in playlists) {
      if (playlist.id == id) return playlist;
    }
    return null;
  }

  UserPlaylist? named(String name) => _named(name);

  UserPlaylist? _named(String name) {
    for (final playlist in playlists) {
      if (playlist.name == name) return playlist;
    }
    return null;
  }

  String _short(String title) {
    if (title.length <= 24) return title;
    return '${title.substring(0, 24)}...';
  }
}
