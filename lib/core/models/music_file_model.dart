import 'package:hive/hive.dart';

part 'music_file_model.g.dart';

@HiveType(typeId: 0)
class MusicFile extends HiveObject {
  MusicFile({required this.path, required this.title});

  @HiveField(0)
  final String path;

  @HiveField(1)
  final String title;
}
