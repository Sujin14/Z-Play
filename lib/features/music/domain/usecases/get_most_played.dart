import '../entities/music_file_entity.dart';
import '../repositories/music_repository.dart';

class GetMostPlayed {
  final MusicRepository repository;

  GetMostPlayed(this.repository);

  Future<List<MusicFileEntity>> call(int limit) async {
    return await repository.getMostPlayedSongs(limit);
  }
}
