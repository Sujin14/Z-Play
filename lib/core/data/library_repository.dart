import '../models/media_access_model.dart';
import '../services/media_permission_service.dart';
import 'library_store.dart';
import 'song_scanner.dart';
import '../models/library_settings_model.dart';
import '../models/song_model.dart';
import '../models/playback_snapshot_model.dart';
import '../models/scan_result_model.dart';

class LibraryRepository {
  LibraryRepository({
    required LibraryStore store,
    required SongScanner scanner,
    required MediaPermissionService permissions,
  })  : _store = store,
        _scanner = scanner,
        _permissions = permissions;

  final LibraryStore _store;
  final SongScanner _scanner;
  final MediaPermissionService _permissions;
  List<Song> _songs = const [];

  List<Song> get songs => List.unmodifiable(_songs);

  Song? songByPath(String path) {
    for (final song in _songs) {
      if (song.path == path) return song;
    }
    return null;
  }

  Future<ScanResult> load({bool refresh = false}) async {
    if (!refresh) {
      final cached = _store.cachedSongs();
      if (cached.isNotEmpty) {
        _songs = cached;
        return ScanResult(songs: songs, access: MediaAccess.granted);
      }
    }
    // Waits for the user's answer, so granting access goes straight on to
    // the scan.
    final access = await _permissions.request();
    final result = await _scanner.scan(access: access);
    _songs = result.songs;
    if (result.songs.isNotEmpty) {
      await _store.cacheSongs(result.songs);
    }
    return result;
  }

  Future<void> openPermissionSettings() => _permissions.openSettings();

  Future<bool> toggleFavorite(Song song) => _store.toggleFavorite(song.path);

  List<String> favoritePaths() => _store.favoritePaths();

  List<String> recentPaths() => _store.recentPaths();

  Map<String, int> playCounts() => _store.playCounts();

  Future<void> recordPlay(Song song) async {
    await _store.rememberPlayed(song.path);
    await _store.incrementPlayCount(song.path);
  }

  LibrarySettings settings() => _store.settings();

  Future<void> saveSettings(LibrarySettings settings) =>
      _store.saveSettings(settings);

  PlaybackSnapshot playback() => _store.playback();

  Future<void> savePlayback(PlaybackSnapshot snapshot) =>
      _store.savePlayback(snapshot);

  Future<void> clearPlayback() => _store.clearPlayback();
}
