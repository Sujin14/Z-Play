import 'package:hive/hive.dart';
part '../adapters/music_file.g.dart';

@HiveType(typeId: 0)
class MusicFile extends HiveObject {
  @HiveField(0)
  final String path;

  @HiveField(1)
  final String title;

  MusicFile({required this.path, required this.title});
}