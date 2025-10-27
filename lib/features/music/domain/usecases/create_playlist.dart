import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class CreatePlaylist {
  final PlaylistRepository repository;

  CreatePlaylist(this.repository);

  Future<void> call(PlaylistEntity playlist) async {
    await repository.createPlaylist(playlist);
  }
}
