import 'package:hive/hive.dart';
import '../../model/model.dart';

/// **Handles Hive Storage for Favorites, Playlists, and Recently Played Songs**
class HiveStorage {
  static List<MusicFile> favorites = [];
  static List<Playlist> playlists = [];
  static List<MusicFile> recentlyPlayed = [];

  /// **Load Favorites from Hive Storage**
  static void loadFavorites() {
    var favoritesBox = Hive.box<String>('favorites');
    favorites = favoritesBox.values
        .map((path) => MusicFile(path: path, title: path.split('/').last))
        .toList();
  }

  /// **Get Favorites List (Returns Cached Data)**
  static List<MusicFile> getFavorites() {
    return favorites;
  }

  /// **Toggle Favorite Status**
  static void toggleFavorite(MusicFile musicFile) {
    var favoritesBox = Hive.box<String>('favorites');
    if (favoritesBox.containsKey(musicFile.path)) {
      favoritesBox.delete(musicFile.path);
    } else {
      favoritesBox.put(musicFile.path, musicFile.path);
    }
    loadFavorites(); // Reload favorites to ensure consistency
  }

  /// **Check if a Song is in Favorites**
  static bool isFavorite(MusicFile musicFile) {
    return Hive.box<String>('favorites').containsKey(musicFile.path);
  }

  /// **Load Playlists from Hive**
  static void loadPlaylists() {
    var playlistsBox = Hive.box<Playlist>('playlistsBox');
    playlists = List<Playlist>.from(playlistsBox.values);
  }

  /// **Create a New Playlist**
  static Future<void> createPlaylist(String playlistName) async {
    var playlistsBox = Hive.box<Playlist>('playlistsBox');
    var newPlaylist = Playlist(name: playlistName, songs: []);
    await playlistsBox.add(newPlaylist);
    playlists.add(newPlaylist);
  }

  /// **Add Song to a Playlist**
  static Future<void> addSongToPlaylist(
      Playlist playlist, MusicFile song) async {
    if (!playlist.songs.contains(song)) {
      playlist.songs.add(song);
      await playlist.save();
    }
  }

  /// **Remove Song from a Playlist**
  static Future<void> removeSongFromPlaylist(
      Playlist playlist, MusicFile song) async {
    playlist.songs.remove(song);
    await playlist.save();
  }

  /// **Delete a Playlist**
  static Future<void> deletePlaylist(Playlist playlist) async {
    await playlist.delete();
    playlists.remove(playlist);
  }

  /// **Load Recently Played Songs**
  static void loadRecentlyPlayed() {
    var recentlyPlayedBox = Hive.box('recentlyPlayedBox');
    List<String> storedPaths = List<String>.from(
        recentlyPlayedBox.get('recentlyPlayed', defaultValue: <String>[]));

    recentlyPlayed = storedPaths
        .map((path) => MusicFile(path: path, title: path.split('/').last))
        .toList();
  }

  /// **Add a Song to Recently Played**
  static void addRecentlyPlayed(MusicFile musicFile) {
    recentlyPlayed.removeWhere((song) => song.path == musicFile.path);
    recentlyPlayed.insert(0, musicFile);

    if (recentlyPlayed.length > 10) {
      recentlyPlayed = recentlyPlayed.sublist(0, 10);
    }

    _saveRecentlyPlayedToHive();
  }

  /// **Save Recently Played Songs to Hive**
  static void _saveRecentlyPlayedToHive() {
    var recentlyPlayedBox = Hive.box('recentlyPlayedBox');
    recentlyPlayedBox.put(
        'recentlyPlayed', recentlyPlayed.map((song) => song.path).toList());
  }
}
