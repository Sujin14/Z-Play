import 'package:hive/hive.dart';
import 'music_file.dart';
part '../adapters/playlist.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<MusicFile> songs;

  Playlist({required this.name, required this.songs});
}