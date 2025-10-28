import '../entities/music_file_entity.dart';
import '../repositories/music_repository.dart';

class ToggleFavorite {
  final MusicRepository repository;

  ToggleFavorite(this.repository);

  Future<void> call(MusicFileEntity musicFile) async {
    await repository.toggleFavorite(musicFile);
  }
}