import 'package:hive/hive.dart';
part 'model.g.dart';

@HiveType(typeId: 0)
class MusicFile extends HiveObject {
  @HiveField(0)
  final String path;

  @HiveField(1)
  final String title;

  MusicFile({required this.path, required this.title});
}

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<MusicFile> songs;

  Playlist({required this.name, required this.songs});
}
