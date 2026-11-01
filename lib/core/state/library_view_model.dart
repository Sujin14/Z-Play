import 'package:flutter/foundation.dart';

import '../models/library_settings_model.dart';
import '../models/media_access_model.dart';
import '../models/song_model.dart';
import '../data/library_repository.dart';
import '../models/collection_kind_model.dart';
import '../models/scan_result_model.dart';
import '../models/song_group_model.dart';
import '../models/song_sort_model.dart';

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel(this._repository);

  final LibraryRepository _repository;
  VoidCallback? onCatalogChanged;

  bool loading = false;
  String? error;
  MediaAccess access = MediaAccess.granted;
  String query = '';
  SongSort sort = SongSort.title;
  LibrarySettings settings = const LibrarySettings();

  List<Song> _songs = const [];
  List<String> _favoritePaths = const [];
  List<String> _recentPaths = const [];
  Map<String, int> _playCounts = const {};

  List<Song> get songs => List.unmodifiable(_visible());

  List<Song> get favorites => [
        for (final path in _favoritePaths)
          if (_song(path) != null) _song(path)!,
      ];

  List<Song> get recentlyPlayed => [
        for (final path in _recentPaths)
          if (_song(path) != null) _song(path)!,
      ];

  List<Song> get mostPlayed {
    final ranked = _playCounts.entries
        .where((entry) => entry.value > 5)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final entry in ranked.take(20))
        if (_song(entry.key) != null) _song(entry.key)!,
    ];
  }

  int playsOf(Song song) => _playCounts[song.path] ?? 0;

  Song? findByPath(String path) => _song(path);

  List<SongGroup> get folders => _groups(
        (song) => song.folderPath,
        (song) => song.folderName,
      );

  List<SongGroup> get albums => _groups(
        (song) => song.album,
        (song) => song.album,
      );

  List<SongGroup> get artists => _groups(
        (song) => song.artist,
        (song) => song.artist,
      );

  List<Song> songsFor(CollectionKind kind, String id) {
    return switch (kind) {
      CollectionKind.folder => folders,
      CollectionKind.album => albums,
      CollectionKind.artist => artists,
    }
        .where((group) => group.id == id)
        .expand((group) => group.songs)
        .toList();
  }

  Future<void> load() async {
    settings = _repository.settings();
    await _reload(refresh: false);
  }

  Future<void> rescan() => _reload(refresh: true);

  Future<void> openPermissionSettings() => _repository.openPermissionSettings();

  Future<void> syncActivity() async {
    _favoritePaths = _repository.favoritePaths();
    _recentPaths = _repository.recentPaths();
    _playCounts = _repository.playCounts();
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setSort(SongSort value) {
    sort = value;
    notifyListeners();
  }

  Future<void> updateSettings(LibrarySettings value) async {
    settings = value;
    await _repository.saveSettings(value);
    notifyListeners();
  }

  Future<void> hideFolder(String folderPath) async {
    if (settings.hiddenFolders.contains(folderPath)) return;
    await updateSettings(
      settings.copyWith(hiddenFolders: [...settings.hiddenFolders, folderPath]),
    );
  }

  Future<void> unhideFolder(String folderPath) async {
    await updateSettings(
      settings.copyWith(
        hiddenFolders: [
          for (final folder in settings.hiddenFolders)
            if (folder != folderPath) folder,
        ],
      ),
    );
  }

  Future<bool> toggleFavorite(Song song) async {
    final added = await _repository.toggleFavorite(song);
    await syncActivity();
    return added;
  }

  bool isFavorite(Song song) => _favoritePaths.contains(song.path);

  Future<void> _reload({required bool refresh}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final ScanResult result = await _repository.load(refresh: refresh);
      _songs = _repository.songs;
      error = result.error;
      access = result.access;
      await syncActivity();
      onCatalogChanged?.call();
    } catch (exception) {
      error = 'Could not read the music library.';
      debugPrint('Library load failed: $exception');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Song? _song(String path) {
    for (final song in _songs) {
      if (song.path == path) return song;
    }
    return null;
  }

  List<Song> _visible() {
    final needle = query.trim().toLowerCase();
    final visible = _songs.where((song) {
      if (!settings.includeSystemSounds && song.isSystemSound) return false;
      if (!settings.includeShortClips &&
          song.durationMs > 0 &&
          song.durationMs < LibrarySettings.minimumClipMs) {
        return false;
      }
      if (_isHidden(song)) return false;
      if (needle.isEmpty) return true;
      return song.title.toLowerCase().contains(needle) ||
          song.artist.toLowerCase().contains(needle) ||
          song.album.toLowerCase().contains(needle) ||
          song.genre.toLowerCase().contains(needle);
    }).toList();

    visible.sort((a, b) {
      return switch (sort) {
        SongSort.title =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        SongSort.artist =>
          a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        SongSort.album =>
          a.album.toLowerCase().compareTo(b.album.toLowerCase()),
        SongSort.duration => b.durationMs.compareTo(a.durationMs),
        SongSort.dateAdded => b.dateAddedMs.compareTo(a.dateAddedMs),
      };
    });
    return visible;
  }

  bool _isHidden(Song song) {
    final folder = song.folderPath.replaceAll('\\', '/');
    for (final hidden in settings.hiddenFolders) {
      final normalized = hidden.replaceAll('\\', '/');
      if (folder == normalized || folder.startsWith('$normalized/')) {
        return true;
      }
    }
    return false;
  }

  List<SongGroup> _groups(
      String Function(Song) id, String Function(Song) title) {
    final grouped = <String, List<Song>>{};
    for (final song in _visible()) {
      grouped.putIfAbsent(id(song), () => []).add(song);
    }
    final groups = [
      for (final entry in grouped.entries)
        SongGroup(
          id: entry.key,
          title: title(entry.value.first),
          subtitle: '${entry.value.length} tracks',
          songs: entry.value,
        ),
    ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return groups;
  }
}
