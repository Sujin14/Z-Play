import '../entities/playlist_entity.dart';
import '../entities/music_file_entity.dart';

abstract class PlaylistRepository {
  Future<void> createPlaylist(PlaylistEntity playlist);
  Future<void> addSongToPlaylist(PlaylistEntity playlist, MusicFileEntity song);
  Future<void> removeSongFromPlaylist(PlaylistEntity playlist, MusicFileEntity song);
  Future<void> deletePlaylist(PlaylistEntity playlist);
  Future<List<PlaylistEntity>> getPlaylists();
}