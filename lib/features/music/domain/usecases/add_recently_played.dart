import '../entities/music_file_entity.dart';
import '../repositories/music_repository.dart';

class AddRecentlyPlayed {
  final MusicRepository repository;

  AddRecentlyPlayed(this.repository);

  Future<void> call(MusicFileEntity musicFile) async {
    await repository.addRecentlyPlayed(musicFile);
  }
}