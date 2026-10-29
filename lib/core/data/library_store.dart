import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/library_settings_model.dart';
import '../models/music_file_model.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../models/playback_snapshot_model.dart';

class LibraryStore {
  LibraryStore({
    required Box<String> favoritesBox,
    required Box<Playlist> playlistBox,
    required Box<dynamic> legacyRecentBox,
    required Box<int> playCountBox,
    required Box<dynamic> preferencesBox,
  })  : _favoritesBox = favoritesBox,
        _playlistBox = playlistBox,
        _legacyRecentBox = legacyRecentBox,
        _playCountBox = playCountBox,
        _preferencesBox = preferencesBox;

  final Box<String> _favoritesBox;
  final Box<Playlist> _playlistBox;
  final Box<dynamic> _legacyRecentBox;
  final Box<int> _playCountBox;
  final Box<dynamic> _preferencesBox;

  List<String> favoritePaths() => _favoritesBox.keys.cast<String>().toList();

  bool isFavorite(String path) => _favoritesBox.containsKey(path);

  Future<bool> toggleFavorite(String path) async {
    if (_favoritesBox.containsKey(path)) {
      await _favoritesBox.delete(path);
      return false;
    }
    await _favoritesBox.put(path, path);
    return true;
  }

  List<Playlist> playlists() => _playlistBox.values.toList();

  Future<void> createPlaylist(String name, List<Song> songs) async {
    await _playlistBox.add(
      Playlist(
        name: name,
        songs: [
          for (final song in songs)
            MusicFile(path: song.path, title: song.title)
        ],
      ),
    );
  }

  Future<String?> renamePlaylist(String name, String newName) async {
    final playlist = _playlistNamed(name);
    if (playlist == null) return 'Playlist not found';
    playlist.name = newName;
    await playlist.save();
    return null;
  }

  Future<void> replaceSongs(String name, List<Song> songs) async {
    final playlist = _playlistNamed(name);
    if (playlist == null) return;
    playlist.songs
      ..clear()
      ..addAll([
        for (final song in songs) MusicFile(path: song.path, title: song.title),
      ]);
    await playlist.save();
  }

  Future<void> addSong(String playlistName, Song song) async {
    final playlist = _playlistNamed(playlistName);
    if (playlist == null) return;
    final exists = playlist.songs.any((item) => item.path == song.path);
    if (exists) return;
    playlist.songs.add(MusicFile(path: song.path, title: song.title));
    await playlist.save();
  }

  Future<void> removeSong(String playlistName, String path) async {
    final playlist = _playlistNamed(playlistName);
    if (playlist == null) return;
    playlist.songs.removeWhere((song) => song.path == path);
    await playlist.save();
  }

  Future<void> deletePlaylist(String name) async {
    final playlist = _playlistNamed(name);
    if (playlist == null) return;
    await playlist.delete();
  }

  Playlist? _playlistNamed(String name) {
    for (final playlist in _playlistBox.values) {
      if (playlist.name == name) return playlist;
    }
    return null;
  }

  List<String> recentPaths() {
    final stored = _preferencesBox.get('recent');
    if (stored is List && stored.isNotEmpty) {
      return stored.cast<String>();
    }
    final legacy =
        _legacyRecentBox.get('recentlyPlayed', defaultValue: <String>[]);
    if (legacy is List) return legacy.cast<String>();
    return const [];
  }

  Future<void> rememberPlayed(String path) async {
    final paths = recentPaths().where((item) => item != path).toList();
    paths.insert(0, path);
    if (paths.length > 20) {
      paths.removeRange(20, paths.length);
    }
    await _preferencesBox.put('recent', paths);
  }

  Map<String, int> playCounts() {
    return {
      for (final key in _playCountBox.keys)
        if (key is String) key: _playCountBox.get(key) ?? 0,
    };
  }

  Future<void> incrementPlayCount(String path) async {
    final next = (_playCountBox.get(path) ?? 0) + 1;
    await _playCountBox.put(path, next);
  }

  List<Song> cachedSongs() {
    final raw = _preferencesBox.get('library');
    if (raw is! String || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        if (item is Map) Song.fromJson(Map<String, dynamic>.from(item)),
    ].where((song) => song.path.isNotEmpty).toList();
  }

  Future<void> cacheSongs(List<Song> songs) async {
    await _preferencesBox.put(
      'library',
      jsonEncode([for (final song in songs) song.toJson()]),
    );
  }

  LibrarySettings settings() {
    final hidden = _preferencesBox.get('hiddenFolders');
    return LibrarySettings(
      darkTheme: _preferencesBox.get('darkTheme', defaultValue: true) as bool,
      includeShortClips:
          _preferencesBox.get('includeShortClips', defaultValue: false) as bool,
      includeSystemSounds: _preferencesBox.get('includeSystemSounds',
          defaultValue: false) as bool,
      hiddenFolders: hidden is List ? hidden.cast<String>() : const [],
    );
  }

  Future<void> saveSettings(LibrarySettings settings) async {
    await _preferencesBox.put('darkTheme', settings.darkTheme);
    await _preferencesBox.put('includeShortClips', settings.includeShortClips);
    await _preferencesBox.put(
        'includeSystemSounds', settings.includeSystemSounds);
    await _preferencesBox.put('hiddenFolders', settings.hiddenFolders);
  }

  PlaybackSnapshot playback() {
    final paths = _preferencesBox.get('queue');
    return PlaybackSnapshot(
      paths: paths is List ? paths.cast<String>() : const [],
      index: _preferencesBox.get('queueIndex', defaultValue: 0) as int,
      positionMs: _preferencesBox.get('positionMs', defaultValue: 0) as int,
      speed:
          (_preferencesBox.get('speed', defaultValue: 1.0) as num).toDouble(),
    );
  }

  Future<void> savePlayback(PlaybackSnapshot snapshot) async {
    await _preferencesBox.put('queue', snapshot.paths);
    await _preferencesBox.put('queueIndex', snapshot.index);
    await _preferencesBox.put('positionMs', snapshot.positionMs);
    await _preferencesBox.put('speed', snapshot.speed);
  }

  Future<void> clearPlayback() async {
    await savePlayback(PlaybackSnapshot.empty);
  }
}
