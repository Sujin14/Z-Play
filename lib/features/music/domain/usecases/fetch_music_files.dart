import '../entities/music_file_entity.dart';
import '../repositories/music_repository.dart';

class FetchMusicFiles {
  final MusicRepository repository;

  FetchMusicFiles(this.repository);

  Future<List<MusicFileEntity>> call() async {
    return await repository.fetchMusicFiles();
  }
}
