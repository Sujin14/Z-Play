import 'music_file_entity.dart';

class PlaylistEntity {
  final String name;
  final List<MusicFileEntity> songs;

  PlaylistEntity({required this.name, required this.songs});
}