import '../entities/music_file_entity.dart';

abstract class MusicRepository {
  Future<List<MusicFileEntity>> fetchMusicFiles();
  Future<void> toggleFavorite(MusicFileEntity musicFile);
  Future<void> addRecentlyPlayed(MusicFileEntity musicFile);
  Future<List<MusicFileEntity>> getFavorites();
  Future<List<MusicFileEntity>> getRecentlyPlayed();
  Future<void> incrementPlayCount(String path);
  Future<List<MusicFileEntity>> getMostPlayedSongs(int limit);
}
