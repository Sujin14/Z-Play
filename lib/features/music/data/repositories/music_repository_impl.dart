import 'package:musicplayer/core/permissions/file_scanner.dart';
import 'package:musicplayer/core/storage/hive_storage.dart';
import '../../domain/entities/music_file_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../models/music_file.dart';

class MusicRepositoryImpl implements MusicRepository {
  final HiveStorage hiveStorage;
  List<MusicFileEntity>? _cachedMusicFiles;

  MusicRepositoryImpl({required this.hiveStorage});

  @override
  Future<List<MusicFileEntity>> fetchMusicFiles() async {
    if (_cachedMusicFiles != null) {
      return _cachedMusicFiles!;
    }
    final musicFiles = await FileScanner.fetchAllMusicFiles();
    _cachedMusicFiles = musicFiles
        .map((file) => MusicFileEntity(path: file.path, title: file.title))
        .toList();
    return _cachedMusicFiles!;
  }

  @override
  Future<void> toggleFavorite(MusicFileEntity musicFile) async {
    HiveStorage.toggleFavorite(
        MusicFile(path: musicFile.path, title: musicFile.title));
  }

  @override
  Future<void> addRecentlyPlayed(MusicFileEntity musicFile) async {
    HiveStorage.addRecentlyPlayed(
        MusicFile(path: musicFile.path, title: musicFile.title));
  }

  @override
  Future<List<MusicFileEntity>> getFavorites() async {
    return HiveStorage.getFavorites()
        .map((file) => MusicFileEntity(path: file.path, title: file.title))
        .toList();
  }

  @override
  Future<List<MusicFileEntity>> getRecentlyPlayed() async {
    return HiveStorage.getRecentlyPlayed()
        .map((file) => MusicFileEntity(path: file.path, title: file.title))
        .toList();
  }

  @override
  Future<void> incrementPlayCount(String path) async {
    HiveStorage.incrementPlayCount(path);
  }

  @override
  Future<List<MusicFileEntity>> getMostPlayedSongs(int limit) async {
    final playCounts = HiveStorage.getPlayCountsFiltered(5);
    final allSongs = await fetchMusicFiles();
    final validSongs =
        allSongs.where((song) => playCounts.containsKey(song.path)).toList();
    validSongs.sort(
        (a, b) => (playCounts[b.path] ?? 0).compareTo(playCounts[a.path] ?? 0));
    return validSongs.take(limit).toList();
  }
}
