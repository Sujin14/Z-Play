import 'package:musicplayer/features/music/domain/entities/playlist_entity.dart';
import 'package:musicplayer/features/music/domain/repositories/playlist_repository.dart';

class GetPlaylists {
  final PlaylistRepository repository;
  GetPlaylists(this.repository);
  Future<List<PlaylistEntity>> call() async {
    return await repository.getPlaylists();
  }
}
