import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../model/model.dart';

class PlaylistProvider with ChangeNotifier {
  List<Playlist> _playlists = [];
  final List<MusicFile> _selectedSongs = [];
  final Box<Playlist> _playlistsBox = Hive.box<Playlist>('playlistsBox');

  /// **Getters**
  List<Playlist> get playlists => _playlists;
  List<MusicFile> get selectedSongs => _selectedSongs;

  /// **Constructor: Loads Playlists from Hive**
  PlaylistProvider() {
    _loadPlaylistsFromHive();
  }

  /// **Loads Playlists from Hive Storage**
  void _loadPlaylistsFromHive() {
    _playlists = _playlistsBox.values.toList();
    notifyListeners();
  }

  /// **Creates a New Playlist and Returns Its Key**
  Future<int> createPlaylist(Playlist newPlaylist) async {
    if (newPlaylist.name.isEmpty) return -1; // Prevent empty playlist names

    final key = await _playlistsBox.add(newPlaylist);
    _playlists.add(newPlaylist); // Avoid reloading entire list
    notifyListeners();
    return key;
  }

  /// **Toggles Song Selection for Bulk Actions**
  void toggleSongSelection(MusicFile song) {
    _selectedSongs.contains(song)
        ? _selectedSongs.remove(song)
        : _selectedSongs.add(song);
    notifyListeners();
  }

  /// **Clears Selected Songs for Bulk Actions**
  void clearSelectedSongs() {
    if (_selectedSongs.isNotEmpty) {
      _selectedSongs.clear();
      notifyListeners();
    }
  }

  /// **Adds a Song to a Playlist (Avoids Duplicates)**
  Future<void> addSongToPlaylist(Playlist playlist, MusicFile song) async {
    if (!playlist.songs.any((s) => s.path == song.path)) {
      playlist.songs.add(song);
      await playlist.save();
      notifyListeners();
    }
  }

  /// **Removes a Song from a Playlist**
  Future<void> removeSongFromPlaylist(Playlist playlist, MusicFile song) async {
    if (playlist.songs.remove(song)) {
      await playlist.save();
      notifyListeners();
    }
  }

  /// **Deletes a Playlist**
  Future<void> deletePlaylist(Playlist playlist) async {
    await playlist.delete();
    _playlists.remove(playlist); // Avoid reloading all playlists
    notifyListeners();
  }

  /// **Disposes Hive Box to Prevent Memory Leaks**
  @override
  void dispose() {
    _playlistsBox.close();
    super.dispose();
  }
}
