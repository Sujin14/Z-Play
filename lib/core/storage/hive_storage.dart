import 'package:hive/hive.dart';
import '../../features/music/data/models/music_file.dart';
import '../../features/music/data/models/playlist.dart';

class HiveStorage {
  static List<MusicFile> favorites = [];
  static List<Playlist> playlists = [];
  static List<MusicFile> recentlyPlayed = [];
  static Map<String, int> playCounts = {};

  static void loadFavorites() {
    var favoritesBox = Hive.box<String>('favorites');
    favorites = favoritesBox.values
        .map((path) => MusicFile(path: path, title: path.split('/').last))
        .toList();
  }

  static List<MusicFile> getFavorites() {
    loadFavorites();
    return favorites;
  }

  static void toggleFavorite(MusicFile musicFile) {
    var favoritesBox = Hive.box<String>('favorites');
    if (favoritesBox.containsKey(musicFile.path)) {
      favoritesBox.delete(musicFile.path);
    } else {
      favoritesBox.put(musicFile.path, musicFile.path);
    }
    loadFavorites();
  }

  static bool isFavorite(MusicFile musicFile) {
    return Hive.box<String>('favorites').containsKey(musicFile.path);
  }

  static void loadPlaylists() {
    var playlistsBox = Hive.box<Playlist>('playlistsBox');
    playlists = List<Playlist>.from(playlistsBox.values);
  }

  static List<Playlist> getPlaylists() {
    loadPlaylists();
    return playlists;
  }

  static Future<void> createPlaylist(String playlistName) async {
    var playlistsBox = Hive.box<Playlist>('playlistsBox');
    var newPlaylist = Playlist(name: playlistName, songs: []);
    await playlistsBox.add(newPlaylist);
    loadPlaylists();
  }

  static Future<void> addSongToPlaylist(
      Playlist playlist, MusicFile song) async {
    if (!playlist.songs.any((s) => s.path == song.path)) {
      playlist.songs.add(song);
      await playlist.save();
      loadPlaylists();
    }
  }

  static Future<void> removeSongFromPlaylist(
      Playlist playlist, MusicFile song) async {
    playlist.songs.removeWhere((s) => s.path == song.path);
    await playlist.save();
    loadPlaylists();
  }

  static Future<void> deletePlaylist(Playlist playlist) async {
    await playlist.delete();
    loadPlaylists();
  }

  static void loadRecentlyPlayed() {
    var recentlyPlayedBox = Hive.box('recentlyPlayedBox');
    List<String> storedPaths = List<String>.from(
        recentlyPlayedBox.get('recentlyPlayed', defaultValue: <String>[]));
    recentlyPlayed = storedPaths
        .map((path) => MusicFile(path: path, title: path.split('/').last))
        .toList();
  }

  static List<MusicFile> getRecentlyPlayed() {
    loadRecentlyPlayed();
    return recentlyPlayed;
  }

  static void addRecentlyPlayed(MusicFile musicFile) {
    loadRecentlyPlayed();
    recentlyPlayed.removeWhere((song) => song.path == musicFile.path);
    recentlyPlayed.insert(0, musicFile);
    if (recentlyPlayed.length > 10) {
      recentlyPlayed = recentlyPlayed.sublist(0, 10);
    }
    _saveRecentlyPlayedToHive();
  }

  static void _saveRecentlyPlayedToHive() {
    var recentlyPlayedBox = Hive.box('recentlyPlayedBox');
    recentlyPlayedBox.put(
        'recentlyPlayed', recentlyPlayed.map((song) => song.path).toList());
  }

  static void loadPlayCounts() {
    var playCountsBox = Hive.box<int>('playCountsBox');
    playCounts = playCountsBox.toMap().cast<String, int>();
  }

  static Map<String, int> getPlayCounts() {
    loadPlayCounts();
    return playCounts;
  }

  static void incrementPlayCount(String path) {
    loadPlayCounts();
    playCounts[path] = (playCounts[path] ?? 0) + 1;
    var playCountsBox = Hive.box<int>('playCountsBox');
    playCountsBox.put(path, playCounts[path]!);
  }

  static Map<String, int> getPlayCountsFiltered(int minCount) {
    loadPlayCounts();
    return Map.fromEntries(
      playCounts.entries.where((entry) => entry.value > minCount),
    );
  }
}