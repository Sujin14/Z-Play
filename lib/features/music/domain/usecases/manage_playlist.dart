import '../entities/playlist_entity.dart';
import '../entities/music_file_entity.dart';
import '../repositories/playlist_repository.dart';

class ManagePlaylist {
  final PlaylistRepository repository;

  ManagePlaylist(this.repository);

  Future<void> addSongToPlaylist(
      PlaylistEntity playlist, MusicFileEntity song) async {
    await repository.addSongToPlaylist(playlist, song);
  }

  Future<void> removeSongFromPlaylist(
      PlaylistEntity playlist, MusicFileEntity song) async {
    await repository.removeSongFromPlaylist(playlist, song);
  }

  Future<void> deletePlaylist(PlaylistEntity playlist) async {
    await repository.deletePlaylist(playlist);
  }
}
